return {
  {
    "james-t-larson/posting.nvim",
    config = function()
      require("posting").setup({
        keybinds = {
          {
            binding = "<leader>po",
            command = ":OpenPosting<CR>",
            desc = "Open Posting",
          },
        },
        ui = {
          border = "rounded",
          width = 0.95,
          height = 0.87,
          x = 0.5,
          y = 0.5,
        },
      })
    end,
  },
}
