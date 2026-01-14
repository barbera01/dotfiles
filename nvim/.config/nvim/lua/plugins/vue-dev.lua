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

  -- =========================================================================
  -- DAP Setup for Chrome Debugging
  -- =========================================================================
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- DAP UI is configured in lua/plugins/dap-ui.lua
      -- No need to configure it here to avoid conflicts

      -- Virtual text
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {
          enabled = true,
          highlight_changed_variables = true,
          show_stop_reason = true,
        },
      },

      -- vscode-js-debug wrapper (CRITICAL - this is what you're missing!)
      {
        'mxsdev/nvim-dap-vscode-js',
        build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
        config = function()
          require('dap-vscode-js').setup({
            node_path = 'node',
            debugger_path = vim.fn.stdpath('data') .. '/lazy/vscode-js-debug',
            adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
          })
        end,
      },
    },

    config = function()
      local dap = require('dap')

      -- Breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = 'DapBreakpointCondition' })
      vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DapStopped', linehl = 'DapStoppedLine' })

      -- Configurations
      for _, language in ipairs({ 'typescript', 'javascript', 'vue', 'typescriptreact', 'javascriptreact' }) do
        dap.configurations[language] = {
          {
            type = 'pwa-chrome',
            request = 'launch',
            name = '🚀 Launch Chrome (Vite)',
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}/src',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            type = 'pwa-chrome',
            request = 'attach',
            name = '🔗 Attach to Chrome',
            port = 9222,
            webRoot = '${workspaceFolder}/src',
          },
        }
      end
    end,

    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'DAP: Continue' },
      { '<F9>', function() require('dap').terminate() end, desc = 'DAP: Terminate' },
      { '<F10>', function() require('dap').step_over() end, desc = 'DAP: Step Over' },
      { '<F11>', function() require('dap').step_into() end, desc = 'DAP: Step Into' },
      { '<F12>', function() require('dap').step_out() end, desc = 'DAP: Step Out' },
      { '<Leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Toggle Breakpoint' },
      { '<Leader>du', function() require('dapui').toggle() end, desc = 'DAP: Toggle UI' },
      { '<Leader>dr', function() require('dap').repl.toggle() end, desc = 'DAP: Toggle REPL' },
    },
  },
}
