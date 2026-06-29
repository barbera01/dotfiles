return {
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install() -- installs CLI backend
    end,
    config = function()
      require("dbee").setup({
        sources = {
          require("dbee.sources").MemorySource:new({
            {
              name = "local_sqlite",
              type = "sqlite",
              url = vim.fn.expand("~/test.db"),
            },
          }),
        },
      })
    end,
  },
}
