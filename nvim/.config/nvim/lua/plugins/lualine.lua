return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- Show an indicator when leet mode is active (AI disabled, LSP still on).
    -- Toggle with <leader>ul or :LeetMode (see config/keymaps.lua).
    table.insert(opts.sections.lualine_x, 1, {
      function()
        return "󰊠 LEET"
      end,
      cond = function()
        return vim.g.leetmode == true
      end,
      color = { fg = "#1a1b26", bg = "#f7768e", gui = "bold" },
    })
  end,
}
