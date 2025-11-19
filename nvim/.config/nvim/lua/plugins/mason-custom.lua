return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Remove nil and gopls from auto-install to prevent errors
        "stylua",
        "shfmt",
        "lua-language-server",
        "bash-language-server",
        "terraform-ls",
        "tflint",
        "yaml-language-server",
        "json-lsp",
        "marksman",
        "prettier",
        "eslint_d",
        "typescript-language-server",
      },
      -- Manually exclude problematic servers
      blacklist = { "nil", "gopls" },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      -- Configure specific servers without nil and gopls
      ensure_installed = {
        "lua_ls",
        "bashls", 
        "terraformls",
        "yamlls",
        "jsonls",
        "marksman",
        "ts_ls",
      },
    },
  },
}