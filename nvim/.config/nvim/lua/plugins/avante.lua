return {
  "yetone/avante.nvim",
  lazy = false,
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
  },
  config = function()
    require("avante").setup({
      provider = "ollama",
      providers = {
        ollama = {
          endpoint = "http://127.0.0.1:11434",
          model = "codellama",
          timeout = 60000,
          extra_request_body = {
            temperature = 0.7,
            num_ctx = 32768,
          },
        },
      },
      mode = "agentic",
    })
  end,
}
