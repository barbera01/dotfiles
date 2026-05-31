return {
  "andy/mpr-wrap-nvim",
  dir = "~/repos/local/mpr-nvim-wrap",
  dev = true,
  config = function()
    require("mpremote").setup({
      panel_width = 50,
      keymaps = true,
    })

    -- Recommended keybindings
    vim.keymap.set("n", "<leader>mp", ":MpRemoteToggle<CR>", { desc = "MicroPython panel" })
    vim.keymap.set("n", "<leader>mr", ":MpRemoteRepl<CR>", { desc = "MicroPython REPL" })
  end,
}
