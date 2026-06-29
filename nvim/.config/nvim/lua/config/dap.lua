return {
  -- DAP (Debug Adapter Protocol) setup for Neovim
  -- PowerShell DAP using nvim-dap-powershell plugin
  {
    "jbyuki/one-small-step-for-vimkind",
    lazy = true,
  },
  {
    "mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup()
    end,
  },
}
