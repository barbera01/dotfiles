return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    -- Add group names for leader key prefixes
    opts.spec = opts.spec or {}

    -- Add your custom group names here
    vim.list_extend(opts.spec, {

      { "<leader>P", group = "Posting" },
      { "<leader>d", group = "Debug" },
      { "<leader>C", group = "Compare/Diff" },
      { "<leader>m", group = "MicroPython" },
    })

    return opts
  end,
}
