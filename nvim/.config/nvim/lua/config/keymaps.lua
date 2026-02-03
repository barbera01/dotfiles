-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ============================================================
-- Explorer - Let LazyVim use its default binding
-- Auto-refresh is handled by autocmds.lua
-- ============================================================
-- Note: <leader>e uses LazyVim's default (snacks or neo-tree)
local k9s = require("config.k9s")

-- Manual refresh command
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("redraw!")
end, { desc = "Force Redraw Screen" })

-- ============================================================
-- Debugging Keymaps
-- ============================================================
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
vim.keymap.set("n", "<leader>dd", function()
  require("dap").continue()
end, { desc = "DAP continue (reuse last config)" })

vim.keymap.set("n", "<leader>dd", function()
  require("dap").run_last()
end, { desc = "DAP run last (reuse config)" })

vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "DAP continue (re-evaluate config)" })

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
  if vim.fn.filereadable(".vscode/launch.json") then
    local dap_vscode = require("dap.ext.vscode")
    dap_vscode.load_launchjs(nil, {
      ["pwa-node"] = { "javascript", "javascriptreact" },
    })
  end
  require("dap").continue()
end, { silent = true, desc = "🐛 Start/Continue Debug" })

vim.keymap.set("n", "<leader>~", function()
  Snacks.dashboard()
end, { desc = "Dashboard / Home" })

require("which-key").add({
  { "<leader>k", group = "Kubernetes" },
})

vim.keymap.set("n", "<leader>k", function()
  k9s.toggle()
end, {
  desc = "k9s (Toggle)",
})
