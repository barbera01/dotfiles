return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "mxsdev/nvim-dap-vscode-js",
      build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
      config = function()
        require("dap-vscode-js").setup({
          node_path = "node",
          debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
          adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        })
      end,
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        virt_text_pos = "eol",
        all_frames = false,
        virt_lines = false,
      },
    },
  },
  config = function()
    local dap = require("dap")

    -- === PowerShell Configuration ===
    -- Note: PowerShell debugging in nvim-dap is limited. Consider using VS Code for full PowerShell debugging.
    -- This configuration will disable PowerShell DAP for now.
    -- Uncomment and configure properly if you have a working PowerShell debug adapter.
    
    -- dap.adapters.powershell = {
    --   type = "executable",
    --   command = "pwsh",
    --   args = { "-Command", "-" }
    -- }
    
    -- dap.configurations.ps1 = {
    --   {
    --     type = "powershell",
    --     request = "launch",
    --     name = "Launch PowerShell script",
    --     script = "${file}",
    --     cwd = "${workspaceFolder}",
    --   },
    -- }

    -- === Visuals / Signs ===
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "DapBreakpointLine", numhl = "DapBreakpointNum" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "◉", texthl = "DapBreakpointCondition", linehl = "DapBreakpointLine", numhl = "DapBreakpointCondition" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", numhl = "DapBreakpointRejected" })
    vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", numhl = "DapLogPoint" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedNum" })

    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointNum", { fg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#3d2a2e" })
    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#5c6370", italic = true })
    vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#56b6c2", bold = true })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapStoppedNum", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2c3325" })

    -- === Go Configuration ===
    -- IMPORTANT: native `dlv dap` does NOT support console/integratedTerminal/
    -- runInTerminal (that's a VS Code Go-extension feature). A plain dap
    -- "launch" therefore gives the debuggee no TTY, so interactive stdin
    -- (fmt.Scan, bufio.Scanner over os.Stdin, etc.) hits instant EOF and spins.
    --
    -- For interactive programs we instead run `dlv debug/test --headless`
    -- inside a real nvim terminal (a true PTY = working stdin) and ATTACH over
    -- DAP (mode=remote). The adapter below handles BOTH cases:
    --   * launch        -> spawn `dlv dap` (fine for non-interactive programs)
    --   * attach+remote -> just connect to the headless dlv already running
    dap.adapters.go = function(callback, config)
      if config.request == "attach" and config.mode == "remote" then
        callback({ type = "server", host = config.host or "127.0.0.1", port = config.port })
      else
        callback({
          type = "server",
          port = "${port}",
          executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
        })
      end
    end

    dap.configurations.go = {
      -- Non-interactive launches (no stdin). Output is captured by dap; for
      -- programs that read stdin use the interactive launcher (<leader>dg).
      { type = "go", name = "Debug Current File", request = "launch", program = "${file}" },
      { type = "go", name = "Debug Package",      request = "launch", program = "./${relativeFileDirname}" },
      { type = "go", name = "Test Current File",  request = "launch", mode = "test", program = "${file}" },
      { type = "go", name = "Test Package",       request = "launch", mode = "test", program = "./${relativeFileDirname}" },
      { type = "go", name = "Attach to Process",  request = "attach", processId = require("dap.utils").pick_process },
    }

    -- When execution stops (breakpoint/step), always show the source in a real
    -- CODE window — never the dlv terminal or a dap-ui panel. (Default
    -- `uselast` opens it in whatever window is current, which is often the
    -- terminal → "it opens the file in the terminal window".)
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

    -- Interactive Go debugging. Native `dlv dap` can't give a program a TTY, so
    -- we run `dlv (debug|test) <pkg> --headless` in a terminal split (a real PTY
    -- ⇒ working stdin), attach over DAP, and auto-continue from entry. Verified
    -- end-to-end: the program's menu prints in the split and typed input reaches
    -- it. Usage: set breakpoints, press <leader>dg. Focus stays in your code
    -- window (so dap keymaps work); when the program asks for input, move to the
    -- terminal split below, press `i`, type. dap-ui panels behave as usual.
    local CFG_NAME = "Attach (interactive terminal)"

    -- Ask the OS for a free TCP port so repeated/parallel sessions never clash.
    local function free_port()
      local s = assert((vim.uv or vim.loop).new_tcp())
      s:bind("127.0.0.1", 0)
      local port = s:getsockname().port
      s:close()
      return port
    end

    local function go_debug_interactive(mode)
      mode = mode or "debug"
      if vim.bo.filetype ~= "go" then
        return vim.notify("Not a Go file — open the package you want to debug", vim.log.levels.WARN)
      end
      local pkg_dir = vim.fn.expand("%:p:h")
      local code_win = vim.api.nvim_get_current_win()
      local dlv_port = free_port()
      local logf = "/tmp/dlv-headless-" .. dlv_port .. ".log"
      -- Build the debug binary under TMPDIR (absolute path) so dlv never drops
      -- an `__debug_bin*` into your repo. Removed when the dlv terminal exits.
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
      vim.cmd("botright 15new")
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
            vim.notify("Debugging — program I/O is in the terminal split below (press `i` there to type)", vim.log.levels.INFO)
          end)
        end
      end

      -- Wait for the headless server to accept connections, then attach.
      local tries = 0
      local timer = assert((vim.uv or vim.loop).new_timer())
      timer:start(150, 150, vim.schedule_wrap(function()
        tries = tries + 1
        local probe = (vim.uv or vim.loop).new_tcp()
        probe:connect("127.0.0.1", dlv_port, function(err)
          probe:close()
          if not err then
            if not timer:is_closing() then timer:stop(); timer:close() end
            vim.schedule(function()
              dap.run({
                type = "go",
                name = CFG_NAME,
                request = "attach",
                mode = "remote",
                port = dlv_port,
                stopOnEntry = false,
              })
            end)
          elseif tries > 60 and not timer:is_closing() then
            timer:stop(); timer:close()
            dap.listeners.after["configurationDone"]["go_autocont"] = nil
            vim.schedule(function()
              vim.notify("dlv never came up on :" .. dlv_port .. " — build likely failed; check the terminal split or " .. logf, vim.log.levels.ERROR)
            end)
          end
        end)
      end))
    end

    vim.keymap.set("n", "<leader>dg", function() go_debug_interactive("debug") end, { desc = "Go: debug interactively (terminal stdin)" })

    -- Cleanup: because the interactive flow ATTACHES, a debuggee would otherwise
    -- survive nvim closing — and, released from its ptrace stop, spin at 100% CPU
    -- forever (fmt.Scan EOF loop). Track every launched process id (DAP `process`
    -- event) and make sure it dies when the session ends or nvim exits.
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

    -- === Bash Configuration ===
    dap.adapters.bashdb = {
      type = "executable",
      command = "node",
      args = { vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/out/bashDebug.js" },
    }

    dap.configurations.sh = {
      {
        type = "bashdb",
        request = "launch",
        name = "Launch Bash script",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/opt/homebrew/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        env = {},
        terminalKind = "integrated",
      },
      {
        type = "bashdb",
        request = "launch", 
        name = "Launch Bash script with args",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/opt/homebrew/bin/bash",
        pathMkfifo = "mkfifo", 
        pathPkill = "pkill",
        args = function()
          return vim.split(vim.fn.input("Arguments: ", ""), " ")
        end,
        env = {},
        terminalKind = "integrated",
      },
    }

    -- === JavaScript / TypeScript / Vue ===
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }

    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
        outputCapture = "console",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**" },
      },
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Launch Chrome (Vite)",
        url = "http://localhost:3000",
        webRoot = "${workspaceFolder}/src",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      {
        type = "pwa-chrome",
        request = "attach",
        name = "Attach to Chrome",
        port = 9222,
        webRoot = "${workspaceFolder}/src",
      },
    }

    dap.configurations.javascriptreact = dap.configurations.javascript
    dap.configurations.typescript = dap.configurations.javascript
    dap.configurations.typescriptreact = dap.configurations.javascript
    dap.configurations.vue = dap.configurations.javascript

    -- === .NET (CoreCLR) ===
    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = false,
        console = "internalConsole",
      },
    }

  end,
}
