return {
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    keys = {
      {
        "<leader>k",
        function()
          require("lazy.util").float_term({ "k9s" }, {
            size = { width = 0.9, height = 0.9 },
          })
        end,
        desc = "Open k9s",
      },
    },
  },
}
