return {
  -- Mason, for automatically installing LSPs
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup() -- default config
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "Lua_ls",
          "pyright",
          "tsserver",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "dockerls",
          "bashls",
          "vimls",
          "sumneko_lua",
          "gopls",
          "rust_analyzer",
          "clangd",
          "svelte",
          "tailwindcss",
          "intelephense",
          "vuels",
          "graphql",
          "angularls",
          "denols",
          "jdtls",
          "solargraph",
          "elixirls",
          "hls",
          "cmake",
          "PowerShell_es",
          "terraformls",
          "azure_pipelines_ls",
        },
      })
    end,
  },

  -- LSPConfig, for configuring individual language servers
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.PowerShell_es.setup({})
      lspconfig.terraformls.setup({})
      lspconfig.azure_pipelines_ls.setup({})
    end,
  },
}
