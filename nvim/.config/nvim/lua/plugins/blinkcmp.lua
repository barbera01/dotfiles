return {
  "saghen/blink.cmp",
  dependencies = {
    "saghen/blink.lib",
    "rafamadriz/friendly-snippets",

    {
      "milanglacier/minuet-ai.nvim",
      config = function()
        require("minuet").setup({
          provider = "openai_fim_compatible",
          n_completions = 1, -- single request; avoids serializing on local server
          throttle = 400, -- was defaulting to cloud-tuned ~1500
          debounce = 100, -- was defaulting to ~600
          request_timeout = 3, -- modest; bump if you see cold-cache timeouts
          context_window = 8000, -- default 16000 chars; trim for faster prefill per keystroke
          provider_options = {
            openai_fim_compatible = {
              name = "omlx",
              end_point = "http://127.0.0.1:8000/v1/completions",
              api_key = "OMLX_API_KEY",
              model = "Qwen2.5-Coder-7B-4bit",
              optional = {
                max_tokens = 128,
                temperature = 0.2,
                top_p = 0.9,
              },
            },
          },
        })
      end,
    },
  },

  build = function()
    require("blink.cmp").build():pwait()
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "super-tab" },

    completion = {
      documentation = {
        auto_show = false,
      },
    },

    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        -- "minuet", for local LLM Completion
      },

      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          score_offset = 100,
        },
      },
    },

    fuzzy = {
      implementation = "rust",
    },
  },
}
