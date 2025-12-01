return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    ft = "python", -- only load when editing Python files

    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", mode = "n" },
    },

    opts = {
      search = {},
      options = {},
    },
  },
}
