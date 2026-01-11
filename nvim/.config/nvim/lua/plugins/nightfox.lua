return {
  "EdenEast/nightfox.nvim",
  priority = 1000, -- Ensure it loads before other plugins
  config = function()
    -- Set the colorscheme
    vim.cmd("colorscheme carbonfox") -- Replace 'nordfox' with your desired theme
  end,
}
