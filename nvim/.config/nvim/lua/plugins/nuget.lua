return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("easy-dotnet").setup({})
  end,
  ft = { "cs", "fsharp", "xml" }, -- lazy load on .NET files
}
