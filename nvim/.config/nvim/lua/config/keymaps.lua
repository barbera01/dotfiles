-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
---- In your init.lua
vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end, { silent = true, desc = "DAP Continue" })
vim.keymap.set("n", "<F10>", function()
  require("dap").step_over()
end, { silent = true, desc = "DAP Step Over" })
vim.keymap.set("n", "<F11>", function()
  require("dap").step_into()
end, { silent = true, desc = "DAP Step Into" })
vim.keymap.set("n", "<F12>", function()
  require("dap").step_out()
end, { silent = true, desc = "DAP Step Out" })

-- Additional debugging keymaps
vim.keymap.set("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { silent = true, desc = "DAP Toggle Breakpoint" })

vim.keymap.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { silent = true, desc = "DAP Conditional Breakpoint" })

vim.keymap.set("n", "<leader>dr", function()
  require("dap").repl.open()
end, { silent = true, desc = "DAP REPL" })

vim.keymap.set("n", "<leader>dl", function()
  require("dap").run_last()
end, { silent = true, desc = "DAP Run Last" })

vim.keymap.set("n", "<leader>dt", function()
  require("dap").terminate()
end, { silent = true, desc = "DAP Terminate" })

-- Enhanced DAP UI keymaps with better descriptions
vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { silent = true, desc = "🐛 Toggle Debug UI" })

-- Quick debugging session management
vim.keymap.set("n", "<leader>dq", function()
  require("dap").terminate()
  require("dapui").close()
end, { silent = true, desc = "🐛 Quit Debug Session" })

-- DAP control with visual feedback
vim.keymap.set("n", "<F5>", function()
  if vim.fn.filereadable('.vscode/launch.json') then
    local dap_vscode = require('dap.ext.vscode')
    dap_vscode.load_launchjs(nil, { 
      ['pwa-node'] = {'javascript', 'javascriptreact'} 
    })
  end
  require("dap").continue()
end, { silent = true, desc = "🐛 Start/Continue Debug" })

-- ============================================================================
-- BETTER ERGONOMIC KEYBINDINGS FOR STEPPING THROUGH CODE
-- ============================================================================
-- These are easier to reach than F-keys and more intuitive

-- Continue/Start (easier than F5)
vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { silent = true, desc = "▶ Continue/Start" })

-- Step Over - most common operation (super easy to reach)
vim.keymap.set("n", "<leader>dj", function()
  require("dap").step_over()
end, { silent = true, desc = "⤴ Step Over (next line)" })

-- Step Into - go deeper (j/k navigation metaphor)
vim.keymap.set("n", "<leader>di", function()
  require("dap").step_into()
end, { silent = true, desc = "⤵ Step Into (go deeper)" })

-- Step Out - go back up
vim.keymap.set("n", "<leader>do", function()
  require("dap").step_out()
end, { silent = true, desc = "⤴ Step Out (go back)" })

-- Alternative: Use J/K for stepping (even faster!)
-- Uncomment these if you want super quick stepping
-- vim.keymap.set("n", "<leader>J", function()
--   require("dap").step_over()
-- end, { silent = true, desc = "⤴ Step Over" })
-- 
-- vim.keymap.set("n", "<leader>K", function()
--   require("dap").step_into()
-- end, { silent = true, desc = "⤵ Step Into" })

-- Continue until cursor (super useful!)
vim.keymap.set("n", "<leader>dC", function()
  require("dap").run_to_cursor()
end, { silent = true, desc = "⏭ Run to Cursor" })

-- Restart debugging session
vim.keymap.set("n", "<leader>dR", function()
  require("dap").restart()
end, { silent = true, desc = "↻ Restart Debug" })

-- Pause execution
vim.keymap.set("n", "<leader>dp", function()
  require("dap").pause()
end, { silent = true, desc = "⏸ Pause" })

-- Step back (if supported by debugger)
vim.keymap.set("n", "<leader>dk", function()
  require("dap").step_back()
end, { silent = true, desc = "⏮ Step Back" })

-- Quick evaluate under cursor
vim.keymap.set("n", "<leader>dE", function()
  require("dapui").eval()
end, { silent = true, desc = "🔍 Eval under cursor" })

-- Evaluate visual selection
vim.keymap.set("v", "<leader>dE", function()
  require("dapui").eval()
end, { silent = true, desc = "🔍 Eval selection" })



-- Compare / Diff keymaps
vim.keymap.set("n", "<leader>Cf", function()
  vim.cmd("vert diffsplit " .. vim.fn.input("Compare with file: "))
end, { desc = "Compare buffer with file" })

vim.keymap.set("n", "<leader>Cw", "<cmd>windo diffthis<cr>", {
  desc = "Compare open windows",
})

vim.keymap.set("n", "<leader>Co", "<cmd>windo diffoff<cr>", {
  desc = "Diff off (all windows)",
})

vim.keymap.set("n", "<leader>Cs", "<cmd>diffsplit<cr>", {
  desc = "Horizontal diff split",
})

vim.keymap.set("n", "<leader>Cv", "<cmd>vert diffsplit<cr>", {
  desc = "Vertical diff split",
})


vim.keymap.set("n", "<leader>Ci", function()
  local bufs = {}

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    if vim.bo[buf].buftype == "" and name ~= "" then
      table.insert(bufs, { buf = buf, name = name })
    end
  end

  if #bufs ~= 2 then
    vim.notify("Open exactly two file buffers", vim.log.levels.WARN)
    return
  end

  for _, b in ipairs(bufs) do
    if vim.bo[b.buf].modified then
      vim.notify("Save both files before diffing", vim.log.levels.WARN)
      return
    end
  end

  local f1 = vim.fn.fnameescape(bufs[1].name)
  local f2 = vim.fn.fnameescape(bufs[2].name)

  -- 🔑 IMPORTANT: the extra `--`
  vim.cmd("DiffviewOpen --no-index -- " .. f1 .. " " .. f2)
end, { desc = "Inline diff (VS Code style, 2 buffers)" })

-- Compare two open buffers (vimdiff style)
vim.keymap.set("n", "<leader>Ca", function()
  -- Get all file buffers
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    if vim.bo[buf].buftype == "" and name ~= "" then
      table.insert(bufs, { buf = buf, name = name })
    end
  end

  -- Check we have exactly 2 buffers
  if #bufs ~= 2 then
    vim.notify("Open exactly two file buffers to compare", vim.log.levels.WARN)
    return
  end

  -- Check both files are saved
  for _, b in ipairs(bufs) do
    if vim.bo[b.buf].modified then
      vim.notify("Save both files before comparing", vim.log.levels.WARN)
      return
    end
  end

  -- Save current diffopt
  local original_diffopt = vim.opt.diffopt:get()

  -- Enable character-level diff highlighting
  vim.opt.diffopt:append({
    "internal",           -- Use internal diff library
    "algorithm:histogram", -- Better diff algorithm
    "indent-heuristic",   -- Better indentation handling
    "linematch:60",       -- Enable word-level diff (requires nvim 0.9+)
  })

  -- Set up enhanced diff highlighting with better contrast
  -- Red = missing/deleted, Green = present/added
  vim.cmd([[
    highlight DiffAdd guibg=#00ff00 guifg=#000000 gui=bold
    highlight DiffChange guibg=#1a1a2e guifg=#ffffff gui=none
    highlight DiffDelete guibg=#ff0000 guifg=#ffffff gui=bold
    highlight DiffText guibg=#00ff00 guifg=#000000 gui=bold,underline
  ]])

  -- Open files in vertical split with diff mode
  vim.cmd("tabnew " .. vim.fn.fnameescape(bufs[1].name))
  vim.cmd("diffthis")
  vim.cmd("vsplit " .. vim.fn.fnameescape(bufs[2].name))
  vim.cmd("diffthis")

  -- Create autocmd to restore diffopt and highlights when leaving the tab
  local tabpage = vim.api.nvim_get_current_tabpage()
  vim.api.nvim_create_autocmd("TabClosed", {
    pattern = tostring(tabpage),
    once = true,
    callback = function()
      vim.opt.diffopt = original_diffopt
      -- Restore highlights by reloading colorscheme
      vim.cmd("doautocmd ColorScheme")
    end,
  })
end, { desc = "Compare 2 open buffers (vimdiff)" })

-- ============================================================================
-- LEET MODE: disable AI assistance (Copilot ghost text + local-LLM source)
-- while keeping the LSP completion popup (blink with lsp/path/snippets/buffer).
-- ============================================================================
local function toggle_leetmode()
  vim.g.leetmode = not vim.g.leetmode
  local on = vim.g.leetmode
  -- Copilot ghost text
  pcall(vim.cmd, on and "Copilot disable" or "Copilot enable")
  -- blink.cmp's `sources.default` reads vim.g.leetmode to drop the AI ("minuet")
  -- source while leaving lsp/path/snippets/buffer intact (see blinkcmp.lua).
  vim.cmd("redrawstatus") -- refresh the lualine indicator immediately
  vim.notify(
    on and "Leet mode ON — AI disabled, LSP still active" or "Leet mode OFF — AI re-enabled",
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command("LeetMode", toggle_leetmode, { desc = "Toggle leet mode (disable AI, keep LSP)" })
vim.keymap.set("n", "<leader>ul", toggle_leetmode, { desc = "Toggle leet mode (disable AI, keep LSP)" })
