-- LSP Configuration for LazyVim
-- Note: LazyVim handles most LSP setup automatically
-- This file is for custom LSP configurations
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python LSP is configured in lua/plugins/python.lua
        -- via the LazyVim Python extra

        -- Go LSP
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              usePlaceholders = true,
              completeUnimported = true,

              analyses = {
                unusedparams = true,
                unusedwrite = true,
                nilness = true,
                shadow = true,
                unreachable = true,
              },

              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },

              codelenses = {
                generate = true,
                gc_details = false,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
            },
          },
        },

        -- PowerShell LSP
        powershell_es = {
          settings = {
            powershell = {
              codeFormatting = {
                preset = "OTBS",
              },
            },
          },
        },

        -- Terraform LSP
        terraformls = {},

        -- Azure Pipelines LSP
        azure_pipelines_ls = {},

        -- Lua LSP configured by LazyVim by default
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
    },
  },
}
