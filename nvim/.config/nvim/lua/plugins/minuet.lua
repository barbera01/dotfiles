return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "Saghen/blink.cmp" },
    opts = function()
      -- Match the local OpenAI-compatible endpoint already used by Avante.
      -- Minuet expects the name of an environment variable, not the key value.
      vim.env.OMLX_API_KEY = vim.env.OMLX_API_KEY or "tttt"

      return {
        provider = "openai_compatible",
        request_timeout = 3,
        throttle = 1500,
        debounce = 600,
        n_completions = 1,
        notify = "warn",
        blink = {
          -- Keep LLM completion manual by default. Use <A-y> in insert mode.
          enable_auto_complete = false,
        },
        virtualtext = {
          auto_trigger_ft = {},
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            accept_n_lines = "<A-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },
        provider_options = {
          openai_compatible = {
            name = "OMLX",
            api_key = "OMLX_API_KEY",
            end_point = "http://127.0.0.1:8000/v1/chat/completions",
            model = "Qwen2.5-Coder-7B-4bit",
            optional = {
              max_tokens = 128,
              temperature = 0.2,
              top_p = 0.9,
            },
          },
        },
      }
    end,
  },
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap["<A-y>"] = require("minuet").make_blink_map()

      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        async = true,
        timeout_ms = 3000,
        score_offset = 50,
      }

      opts.completion = opts.completion or {}
      opts.completion.trigger = opts.completion.trigger or {}
      opts.completion.trigger.prefetch_on_insert = false
    end,
  },
}
