return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    -- 🔑 THIS IS THE IMPORTANT PART
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
    },

    keys = {
      { "<leader>Cd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
      { "<leader>Cc", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
    },
  },
}
