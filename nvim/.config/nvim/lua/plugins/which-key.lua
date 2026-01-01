return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    -- Add group names for leader key prefixes
    opts.spec = opts.spec or {}

    -- Add your custom group names here
    vim.list_extend(opts.spec, {
      { "<leader>p", group = "Python" }, -- Rename the p menu to "Python"
      { "<leader>P", group = "Posting" }, -- Capital P menu for Posting (HTTP client)
    })

    return opts
  end,
}
