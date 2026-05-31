return {
  "yetone/avante.nvim",
  lazy = false,
  version = false,
  build = "make",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },

  opts = {
    provider = "omlx",
    mode = "agentic",

    providers = {
      omlx = {
        __inherited_from = "openai",
        endpoint = "http://127.0.0.1:8000/v1",
        model = "",
        api_key_name = "OMLX_API_KEY",
        timeout = 60000,
        context_window = 131072,

        extra_request_body = {
          temperature = 0.3,
          max_tokens = 4096,
        },
      },
    },
  },
}

-- 32K = 32,768 tokens
-- 64K = 65,536 tokens
-- 128K = 131,072 tokens
-- 256K = 262,144 tokens
