-- Complete LSP + DAP Setup for Vue.js/TypeScript
-- Add this to your Neovim config: ~/.config/nvim/lua/plugins/vue-dev.lua

return {
  -- =========================================================================
  -- LSP Setup for Vue.js
  -- =========================================================================
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'ts_ls',      -- TypeScript LSP (required by vue_ls)
          'volar',      -- Vue LSP (replaces deprecated vetur/vue_ls)
        },
      })

      local lspconfig = require('lspconfig')

      -- TypeScript LSP
      lspconfig.ts_ls.setup({
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
      })

      -- Vue LSP (modern Volar)
      lspconfig.volar.setup({})
    end,
  },

  -- =========================================================================
  -- DAP Setup for Chrome Debugging
  -- =========================================================================
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- DAP UI
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        config = function()
          local dap, dapui = require('dap'), require('dapui')

          dapui.setup({
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.30 },
                  { id = "breakpoints", size = 0.20 },
                  { id = "stacks", size = 0.30 },
                  { id = "watches", size = 0.20 },
                },
                size = 50,
                position = "left",
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size = 12,
                position = "bottom",
              },
            },
          })

          -- Auto-open/close UI
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },

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
