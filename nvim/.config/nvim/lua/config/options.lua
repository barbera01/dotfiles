-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

-- Disable problematic LSP servers in Mason
vim.g.lazyvim_cmp = "blink.cmp"
