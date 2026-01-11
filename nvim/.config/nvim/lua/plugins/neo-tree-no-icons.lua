-- Neo-tree WITHOUT icons (ASCII only)
-- Use this if terminal can't display Nerd Font icons properly
-- To activate: rename this file to neo-tree.lua (replacing the current one)

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    close_if_last_window = false,
    enable_git_status = true,
    enable_diagnostics = true,

    -- ASCII-only icons (no Nerd Fonts required)
    default_component_configs = {
      icon = {
        folder_closed = "[+]",
        folder_open = "[-]",
        folder_empty = "[ ]",
        default = " ",
      },
      modified = {
        symbol = "[M]",
      },
      git_status = {
        symbols = {
          added     = "[A]",
          modified  = "[M]",
          deleted   = "[D]",
          renamed   = "[R]",
          untracked = "[U]",
          ignored   = "[I]",
          unstaged  = "[*]",
          staged    = "[+]",
          conflict  = "[!]",
        },
      },
      indent = {
        with_expanders = true,
        expander_collapsed = "+",
        expander_expanded = "-",
      },
    },

    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
        always_show = {
          ".gitignore",
          "terraform.tfvars",
        },
      },
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },

    window = {
      width = 35,
    },
  },
}
