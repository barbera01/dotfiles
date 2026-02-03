-- init.lua or plugins config
return {
  {
    "d7omdev/nuget.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("nuget").setup({})
    end,
  },
}
