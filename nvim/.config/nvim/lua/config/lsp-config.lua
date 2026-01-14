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
        
        -- Lua LSP (configured by LazyVim by default)
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
