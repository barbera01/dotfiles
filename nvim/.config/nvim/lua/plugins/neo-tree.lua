-- Neo-tree configuration to show gitignored files and fix icons
return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Ensure icons are loaded
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- Enable icons globally
    enable_git_status = true,
    enable_diagnostics = true,

    -- Icon configuration
    -- If seeing random letters, try ASCII: "[+]", "[-]", "*" instead
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        folder_empty_open = "",
        default = "",
        highlight = "NeoTreeFileIcon",
      },
      modified = {
        symbol = "●",
        highlight = "NeoTreeModified",
      },
      git_status = {
        symbols = {
          added     = "✚",
          modified  = "",
          deleted   = "✖",
          renamed   = "󰁕",
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
      },
      indent = {
        with_expanders = true, -- Enable folder expand/collapse icons
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
    },

    filesystem = {
      filtered_items = {
        visible = true, -- Show filtered items (gitignored, hidden files)
        hide_dotfiles = false, -- Show dotfiles
        hide_gitignored = false, -- Show gitignored files
        hide_hidden = false, -- Show hidden files (Windows)
        hide_by_name = {
          -- Add any files you want to hide here
          -- "node_modules",
        },
        hide_by_pattern = {
          -- Add any patterns you want to hide here
          -- "*.meta",
        },
        always_show = {
          -- Always show these even if filtered
          ".gitignore",
          ".gitattributes",
          "terraform.tfvars",
        },
        never_show = {
          -- Never show these
          ".DS_Store",
          "thumbs.db",
        },
      },
      follow_current_file = {
        enabled = true, -- Focus on current file
      },
      use_libuv_file_watcher = true, -- Auto refresh

      -- Removed custom components - use defaults to avoid rendering issues
    },

    window = {
      width = 35,
      mappings = {
        -- Wrap expand/collapse with auto-refresh
        ["<space>"] = {
          function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              require("neo-tree.sources.filesystem.commands").toggle_node(state)
              -- Force redraw after expand/collapse
              vim.defer_fn(function()
                vim.cmd("redraw!")
              end, 100)
            else
              require("neo-tree.sources.filesystem.commands").open(state)
            end
          end,
          desc = "Toggle node (with refresh)",
        },
        ["<cr>"] = {
          function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              require("neo-tree.sources.filesystem.commands").toggle_node(state)
              vim.defer_fn(function()
                vim.cmd("redraw!")
              end, 100)
            else
              require("neo-tree.sources.filesystem.commands").open(state)
            end
          end,
          desc = "Open/Toggle (with refresh)",
        },
        ["o"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["t"] = "open_tabnew",
        ["C"] = "close_node",
        ["z"] = {
          function(state)
            require("neo-tree.sources.filesystem.commands").close_all_nodes(state)
            vim.defer_fn(function()
              vim.cmd("redraw!")
            end, 100)
          end,
          desc = "Close all nodes (with refresh)",
        },
        ["R"] = {
          function(state)
            require("neo-tree.sources.filesystem.commands").refresh(state)
            vim.defer_fn(function()
              vim.cmd("redraw!")
            end, 100)
          end,
          desc = "Refresh (with redraw)",
        },
        ["a"] = "add",
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["H"] = "toggle_hidden",
        ["I"] = "toggle_gitignore",
        ["?"] = "show_help",
      },
    },
  },
}
