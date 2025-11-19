return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Manual gopls configuration since Mason install fails
        gopls = {
          cmd = { vim.fn.expand("~/go/bin/gopls") },
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