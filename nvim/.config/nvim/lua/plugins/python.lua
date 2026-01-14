-- Import LazyVim's Python language extra for complete Python support
-- This provides: treesitter, LSP (pyright + ruff), DAP debugging, and testing
return {
  -- Import the LazyVim Python extra which sets up everything
  { import = "lazyvim.plugins.extras.lang.python" },

  -- Override/extend the Python LSP configuration if needed
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic", -- or "strict" for more checking
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        ruff = {
          -- Ruff is used for linting and formatting
          -- It's much faster than flake8/black
        },
      },
    },
  },

  -- Enhanced virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        auto_refresh = true,
      },
    },
  },

  -- DAP (Debug Adapter Protocol) for Python debugging
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      -- Use the debugpy adapter installed by Mason
      require("dap-python").setup("debugpy-adapter")
      
      -- Add custom debug configurations
      local dap = require("dap")
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " +")
        end,
        console = "integratedTerminal",
      })
    end,
  },
}
