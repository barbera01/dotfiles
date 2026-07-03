return {
  "EdenEast/nightfox.nvim",
  priority = 1000, -- Ensure it loads before other plugins
  config = function()
    -- carbonfox sets WinSeparator to bg0 (near-black), which is invisible
    -- against a transparent (pure black terminal) background. Use a
    -- visible grey so window splits and dapui panes get a real border.
    -- Re-apply on every ColorScheme event because nvim-transparent's
    -- TransparentEnable re-runs `:colorscheme`, which resets this.
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "carbonfox",
      callback = function()
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#525253" })
      end,
    })

    -- Set the colorscheme
    vim.cmd("colorscheme carbonfox") -- Replace 'nordfox' with your desired theme
  end,
}
