-- Complete LSP + DAP Setup for Vue.js/TypeScript
-- Add this to your Neovim config: ~/.config/nvim/lua/plugins/vue-dev.lua

return {
  -- =========================================================================
  -- LSP Setup for Vue.js
  -- =========================================================================
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        -- TypeScript LSP (required for Vue)
        ts_ls = {
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                languages = { 'vue' },
              },
            },
          },
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
        },
        -- Vue LSP (Volar)
        volar = {},
      },
    },
  },
}
