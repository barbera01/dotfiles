-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Enable autosave when leaving insert mode or switching buffers
vim.api.nvim_create_autocmd({ "TextChanged", "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! wall",
})

-- ============================================================
-- Fix Explorer Rendering Issues
-- ============================================================
local explorer_group = vim.api.nvim_create_augroup("ExplorerRenderFix", { clear = true })

-- Auto-refresh when entering explorer buffers
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype

    -- Check if this is an explorer buffer (snacks or neo-tree)
    if bufname:match("snacks://")
       or filetype == "snacks_explorer"
       or filetype == "neo-tree" then
      -- Force redraw to clear odd characters/random letters
      vim.defer_fn(function()
        vim.cmd("redraw!")
      end, 50)
    end
  end,
  group = explorer_group,
})

-- Auto-refresh after any text change in explorer (expand/collapse/etc)
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "neo-tree" then
      -- Force redraw after tree operations
      vim.defer_fn(function()
        vim.cmd("redraw!")
      end, 50)
    end
  end,
  group = explorer_group,
})

-- Auto-refresh after cursor moves in explorer (expand/collapse)
vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "neo-tree" or ft == "snacks_picker" or ft == "snacks_explorer" then
      -- Debounced redraw to avoid excessive redraws
      vim.defer_fn(function()
        vim.cmd("redraw!")
      end, 150)
    end
  end,
  group = explorer_group,
})

-- Force redraw when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("redraw!")
  end,
  group = vim.api.nvim_create_augroup("ForceRedrawOnResize", { clear = true }),
})
