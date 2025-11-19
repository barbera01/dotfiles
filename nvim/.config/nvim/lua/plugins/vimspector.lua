return {
  "puremourning/vimspector",
  config = function()
    -- Vimspector keymaps
    vim.keymap.set("n", "<F5>", "<Plug>VimspectorContinue", { desc = "Vimspector Continue" })
    vim.keymap.set("n", "<F9>", "<Plug>VimspectorToggleBreakpoint", { desc = "Vimspector Toggle Breakpoint" })
    vim.keymap.set("n", "<F10>", "<Plug>VimspectorStepOver", { desc = "Vimspector Step Over" })
    vim.keymap.set("n", "<F11>", "<Plug>VimspectorStepInto", { desc = "Vimspector Step Into" })
    vim.keymap.set("n", "<F12>", "<Plug>VimspectorStepOut", { desc = "Vimspector Step Out" })
    vim.keymap.set("n", "<leader>dr", "<Plug>VimspectorRestart", { desc = "Vimspector Restart" })
    vim.keymap.set("n", "<leader>ds", "<Plug>VimspectorStop", { desc = "Vimspector Stop" })
    vim.keymap.set("n", "<leader>du", "<Cmd>VimspectorShowOutput<CR>", { desc = "Vimspector Show Output" })
    
    -- Vimspector settings
    vim.g.vimspector_enable_mappings = 'HUMAN'
  end,
}