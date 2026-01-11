return {
  {
    "james-t-larson/posting.nvim",
    config = function()
      local posting_collection = nil

      -- Override OpenPosting to prompt for path if not set
      vim.api.nvim_create_user_command("OpenPosting", function()
        if not posting_collection then
          posting_collection = vim.fn.input("Posting collection path: ", vim.fn.getcwd(), "dir")
          if posting_collection == "" then
            vim.notify("No collection path provided", vim.log.levels.WARN)
            return
          end
          require("posting").setup({
            collection = posting_collection,
            ui = {
              border = "rounded",
              width = 0.95,
              height = 0.87,
              x = 0.5,
              y = 0.5,
            },
          })
        end
        vim.cmd("OpenPosting")
      end, { desc = "Open Posting (prompts for collection if not set)" })

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
