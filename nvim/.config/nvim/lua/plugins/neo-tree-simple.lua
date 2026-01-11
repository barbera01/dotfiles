-- Simplified Neo-tree configuration
-- Use this if you're seeing random letters/escape codes
-- To activate: rename this file to neo-tree.lua (replacing the current one)

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    close_if_last_window = false,
    enable_git_status = true,
    enable_diagnostics = true,

    -- Simplified icon configuration
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        default = "*",
      },
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
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
