return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Let lspconfig resolve gopls from PATH/Mason
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
      },
    },
  },
}
