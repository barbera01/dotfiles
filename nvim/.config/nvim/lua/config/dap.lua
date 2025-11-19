return {
  -- DAP (Debug Adapter Protocol) setup for Neovim
  {
    "Willem-J-an/nvim-dap-powershell",
    config = function()
      require("dap-powershell").setup()
    end,
  },
  {
    "mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup()
    end,
  },
}
