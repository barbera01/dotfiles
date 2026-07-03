-- Shared debugging plumbing used by config/keymaps.lua and the dap plugin
-- specs. This is the "common experience" contract for every language:
--
--   * dap-ui inspector panel on the RIGHT        (lua/plugins/dap-ui.lua)
--   * the program's interactive terminal in a BOTTOM split (TERM_HEIGHT):
--       - Go:   headless dlv in a real terminal (M.go_interactive, below)
--       - Bash: bashdb runInTerminal split (dap.defaults terminal_win_cmd,
--               re-pointed after dapui.setup in lua/plugins/dap-ui.lua)
--       - Pwsh: powershell.nvim extension debug terminal, moved into place
--               by the listener registered in M.setup
--   * <leader>dd starts the right flow for the current filetype
--
-- Adapters/configurations live in lua/plugins/nvim-dap.lua (PowerShell's in
-- lua/plugins/powershell.lua); all keymaps live in lua/config/keymaps.lua.
local M = {}

M.TERM_HEIGHT = 15
-- Window command every interactive debug terminal is opened with.
M.term_cmd = "botright " .. M.TERM_HEIGHT .. "new"

---------------------------------------------------------------------------
-- Go: interactive debugging with a real PTY
---------------------------------------------------------------------------
-- Native `dlv dap` does NOT support console/integratedTerminal/runInTerminal
-- (that's a VS Code Go-extension feature), so a plain dap "launch" gives the
-- debuggee no TTY and interactive stdin (fmt.Scan etc.) hits instant EOF.
-- Instead: run `dlv debug/test --headless` in a terminal split (real PTY =>
-- working stdin), ATTACH over DAP (mode=remote), auto-continue from entry.
local CFG_NAME = "Attach (interactive terminal)"

-- Ask the OS for a free TCP port so repeated/parallel sessions never clash.
local function free_port()
  local s = assert((vim.uv or vim.loop).new_tcp())
  s:bind("127.0.0.1", 0)
  local port = s:getsockname().port
  s:close()
  return port
end

---@param mode "debug"|"test"
function M.go_interactive(mode)
  local dap = require("dap")
  mode = mode or "debug"
  if vim.bo.filetype ~= "go" then
    return vim.notify("Not a Go file — open the package you want to debug", vim.log.levels.WARN)
  end
  local pkg_dir = vim.fn.expand("%:p:h")
  local code_win = vim.api.nvim_get_current_win()
  local dlv_port = free_port()
  local logf = "/tmp/dlv-headless-" .. dlv_port .. ".log"
  -- Build the debug binary under TMPDIR (absolute path) so dlv never drops
  -- an `__debug_bin*` into the repo. Removed when the dlv terminal exits.
  local out_bin = (vim.env.TMPDIR or "/tmp/") .. "dlv-debug-bin-" .. dlv_port

  -- One session at a time: tear down any existing session + stale dlv
  -- terminals so a previous/failed run can't interfere with this one.
  if dap.session() then
    pcall(function() dap.disconnect({ terminateDebuggee = true }) end)
    pcall(function() dap.terminate() end)
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local ok, nm = pcall(vim.api.nvim_buf_get_name, b)
    if ok and vim.bo[b].buftype == "terminal" and nm:match("dlv") then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end

  -- Open the interactive terminal split and run headless dlv in it.
  vim.cmd(M.term_cmd)
  local term_buf = vim.api.nvim_get_current_buf()
  vim.bo[term_buf].buflisted = false
  vim.fn.termopen({
    "dlv", mode, ".",
    "--headless", "--api-version=2",
    -- multiclient keeps the server alive across connection hiccups; without
    -- it dlv is single-client and tears down (ECONNREFUSED) mid-attach.
    "--accept-multiclient",
    "--listen=127.0.0.1:" .. dlv_port,
    "--log-dest=" .. logf,
    "--output=" .. out_bin,
  }, {
    -- Run dlv FROM the package dir with "." as the target so module
    -- resolution works regardless of nvim's cwd (abs paths can error with
    -- "directory outside main module").
    cwd = pkg_dir,
    -- Delete the debug binary (and its dSYM, if any) when dlv exits. Scoped
    -- to this binary only — does NOT touch the dap session.
    on_exit = function()
      vim.fn.delete(out_bin)
      vim.fn.delete(out_bin .. ".dSYM", "rf")
    end,
  })
  -- Keep focus in the code window so <leader>-prefixed dap keymaps work
  -- (in terminal-insert mode, <leader> would just type into the program).
  if vim.api.nvim_win_is_valid(code_win) then vim.api.nvim_set_current_win(code_win) end

  -- After breakpoints are sent (configurationDone), resume from the entry
  -- halt so you land straight in the program. Raw `continue` request mirrors
  -- the verified flow; self-removes so it only affects this session.
  dap.listeners.after["configurationDone"]["go_autocont"] = function(session)
    if session.config and session.config.name == CFG_NAME then
      dap.listeners.after["configurationDone"]["go_autocont"] = nil
      session:request("continue", { threadId = 1 }, function() end)
      vim.schedule(function()
        vim.notify("Debugging — program I/O is in the terminal split below (<leader>dt jumps there ready to type)", vim.log.levels.INFO)
      end)
    end
  end

  -- Wait for the headless server to accept connections, then attach.
  -- Readiness is detected via /proc/net/tcp (LISTEN state), NOT a TCP probe:
  -- dlv >= 1.27 logs a loud multi-line "closing connection from different
  -- user" warning into the terminal for every probe connection it rejects.
  local function port_listening(port)
    local hexport = string.format("%04X", port)
    local f = io.open("/proc/net/tcp", "r")
    if not f then return false end
    for line in f:lines() do
      local addr, state = line:match("^%s*%d+:%s+(%x+:%x+)%s+%x+:%x+%s+(%x+)")
      if addr and state == "0A" and addr:match(":(%x+)$") == hexport then
        f:close()
        return true
      end
    end
    f:close()
    return false
  end

  local tries = 0
  local timer = assert((vim.uv or vim.loop).new_timer())
  timer:start(150, 150, vim.schedule_wrap(function()
    tries = tries + 1
    if port_listening(dlv_port) then
      if not timer:is_closing() then timer:stop(); timer:close() end
      dap.run({
        type = "go",
        name = CFG_NAME,
        request = "attach",
        mode = "remote",
        port = dlv_port,
        stopOnEntry = false,
      })
    elseif tries > 60 and not timer:is_closing() then
      timer:stop(); timer:close()
      dap.listeners.after["configurationDone"]["go_autocont"] = nil
      vim.notify("dlv never came up on :" .. dlv_port .. " — build likely failed; check the terminal split or " .. logf, vim.log.levels.ERROR)
    end
  end))
end

---------------------------------------------------------------------------
-- Common entry points (bound in config/keymaps.lua)
---------------------------------------------------------------------------

-- <leader>dd — start debugging the current file the right way per language.
function M.smart_start()
  if vim.bo.filetype == "go" then
    return M.go_interactive("debug")
  end
  -- Everything else (ps1/sh/js/py/cs/...) launches through its registered
  -- dap configurations; adapters are set up so interactive program I/O
  -- lands in the bottom terminal.
  require("dap").continue()
end

-- <leader>dc / <F5> — continue when a session is running; otherwise start
-- one the right way. Crucially, Go with no session goes INTERACTIVE: the
-- plain "Debug Current File" launch uses native `dlv dap`, which cannot
-- attach a terminal (no runInTerminal), so any stdin read (fmt.Scanln...)
-- hits instant EOF — the classic "I can't type into the terminal" trap.
-- The non-interactive launch configs are still available via <leader>dD.
function M.continue_or_start()
  if require("dap").session() then
    return require("dap").continue()
  end
  M.smart_start()
end

-- <leader>dt — jump into the interactive terminal (and straight to insert
-- mode so typing reaches the program). For PowerShell the extension debug
-- terminal may exist but be hidden — surface it first.
function M.focus_terminal()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_set_current_win(win)
      vim.cmd.startinsert()
      return
    end
  end
  if vim.bo.filetype == "ps1" and package.loaded["powershell"] then
    if pcall(function() require("powershell").toggle_debug_term() end)
        and vim.bo.buftype == "terminal" then
      vim.cmd.wincmd("J")
      vim.api.nvim_win_set_height(0, M.TERM_HEIGHT)
      vim.cmd.startinsert()
      return
    end
  end
  vim.notify("No debug terminal in this tab", vim.log.levels.WARN)
end

---------------------------------------------------------------------------
-- Session-wide behaviour, registered once from lua/plugins/nvim-dap.lua
---------------------------------------------------------------------------
---@param dap table the require("dap") module
function M.setup(dap)
  -- When execution stops (breakpoint/step), always show the source in a real
  -- CODE window — never a terminal or a dap-ui panel. (Default `uselast`
  -- opens it in whatever window is current, which is often the terminal →
  -- "it opens the file in the terminal window".)
  local function is_code_win(win)
    local b = vim.api.nvim_win_get_buf(win)
    if vim.bo[b].buftype ~= "" then return false end
    local ft = vim.bo[b].filetype
    return not ft:match("^dapui_") and ft ~= "dap-repl"
  end
  dap.defaults.fallback.switchbuf = function(bufnr, line, column)
    local function place(win)
      vim.api.nvim_win_set_buf(win, bufnr)
      vim.api.nvim_set_current_win(win)
      pcall(vim.api.nvim_win_set_cursor, win, { line, math.max((column or 1) - 1, 0) })
    end
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, w in ipairs(wins) do          -- 1) a window already showing the file
      if vim.api.nvim_win_get_buf(w) == bufnr then return place(w) end
    end
    local cur = vim.api.nvim_get_current_win()
    if is_code_win(cur) then return place(cur) end   -- 2) current, if it's code
    for _, w in ipairs(wins) do          -- 3) any code window
      if is_code_win(w) then return place(w) end
    end
    vim.cmd("topleft split")             -- 4) none — make one above everything
    place(vim.api.nvim_get_current_win())
  end

  -- PowerShell: powershell.nvim never shows its debug terminal on its own —
  -- when a ps1 session starts, pin it to the standard bottom slot and keep
  -- focus in the code window.
  dap.listeners.after.event_initialized["ps1_show_term"] = function(session)
    if not (session.config and session.config.type == "ps1") then return end
    vim.schedule(function()
      -- already visible? (the extension terminal is a pwsh term:// buffer)
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].buftype == "terminal" and vim.api.nvim_buf_get_name(b):lower():match("pwsh") then
          return
        end
      end
      local cur = vim.api.nvim_get_current_win()
      if pcall(function() require("powershell").toggle_debug_term() end)
          and vim.bo.buftype == "terminal" then
        vim.cmd.wincmd("J")
        vim.api.nvim_win_set_height(0, M.TERM_HEIGHT)
      end
      if vim.api.nvim_win_is_valid(cur) then vim.api.nvim_set_current_win(cur) end
    end)
  end

  -- Cleanup: the Go interactive flow ATTACHES, so a debuggee would otherwise
  -- survive nvim closing — and, released from its ptrace stop, spin at 100%
  -- CPU forever (fmt.Scan EOF loop). Track every launched process id (DAP
  -- `process` event) and make sure it dies when the session ends or nvim exits.
  local owned_pids = {}
  dap.listeners.after.event_process["go_kill_orphans"] = function(_, body)
    if body and body.systemProcessId then owned_pids[body.systemProcessId] = true end
  end
  local function kill_owned()
    pcall(function() require("dap").disconnect({ terminateDebuggee = true }) end)
    for pid in pairs(owned_pids) do pcall(vim.fn.system, { "kill", "-9", tostring(pid) }) end
    owned_pids = {}
  end
  dap.listeners.after.event_terminated["go_kill_orphans"] = kill_owned
  dap.listeners.after.event_exited["go_kill_orphans"] = kill_owned
  vim.api.nvim_create_autocmd("VimLeavePre", { callback = kill_owned, desc = "Kill orphaned dlv debuggees" })
end

return M
