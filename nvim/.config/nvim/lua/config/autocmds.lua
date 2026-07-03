-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- Enable autosave when leaving insert mode or switching buffers
vim.api.nvim_create_autocmd({ "TextChanged", "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! wall",
})
