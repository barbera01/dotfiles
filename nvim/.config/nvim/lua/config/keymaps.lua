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
