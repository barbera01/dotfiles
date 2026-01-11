return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    explorer = {
      enabled = true,
      layout = "left",
      width = 35,
      follow = true,
      hidden = true,
      icons = {
        enabled = true,
        -- Use consistent icons to avoid rendering issues
        folder_closed = "",
        folder_open = "",
        file = "",
        symlink = "",
      },
      filters = {
        gitignore = false,
        dotfiles = false,
        custom = {},
      },
      -- Fix rendering and refresh issues
      format = function(file)
        local icon = ""
        local name = file.name

        -- Get icon from nvim-web-devicons
        if file.type == "directory" then
          icon = file.is_open and "" or ""
        else
          local devicons = require("nvim-web-devicons")
          local file_icon = devicons.get_icon(name, nil, { default = true })
          icon = file_icon or ""
        end

        -- Ensure proper spacing to avoid odd characters
        return icon .. " " .. name
      end,
      -- Auto-refresh on file changes
      auto_cd = true,
      hijack_netrw = true,
      -- Better rendering performance
      redraw = true,
    },
    -- Enable other snacks features
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
}
