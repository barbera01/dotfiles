-- dap-ui: single RIGHT-side inspector panel. The bottom of the screen is the
-- interactive terminal slot (see lua/config/debugging.lua). Keymaps live in
-- lua/config/keymaps.lua.
return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")

    dapui.setup({
      icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "→",
      },

      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },

      element_mappings = {},

      -- Single RIGHT-side inspector panel only. The bottom is intentionally
      -- left free for the interactive terminal (dlv / bashdb / pwsh), so the
      -- two don't fight. `repl` (not `console`) is included here: nvim-dap's
      -- core always appends every OutputEvent (Write-Host, fmt.Println,
      -- bashdb stdout, ...) to the dap-repl buffer regardless of adapter, so
      -- this is a plain passive log with no side effects. `console` is
      -- deliberately NOT added — it's the shared terminal buffer dapui
      -- offers to runInTerminal adapters, which we re-point below.
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.35 },
            { id = "repl",        size = 0.30 },
            { id = "watches",     size = 0.15 },
            { id = "breakpoints", size = 0.12 },
            { id = "stacks",      size = 0.08 },
          },
          size = 60,
          position = "right",
        },
      },

      -- Controls bar attached to scopes (always visible in layout 1)
      controls = {
        enabled = true,
        element = "scopes",
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⤵",
          step_over = "→",
          step_out = "↑",
          step_back = "⏮",
          run_last = "↻",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },

      render = {
        max_type_length = 40,
        -- Keep values from overflowing the panel height
        max_value_lines = 3,
        indent = 1,
      },

      floating = {
        max_height = 0.9,
        max_width = 0.9,
        border = "rounded",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },

      windows = { indent = 1 },

      -- Allow multi-line values but capped by max_value_lines above
      expand_lines = true,
    })

    -- IMPORTANT: dapui.setup() (elements/console.lua) hijacks
    -- dap.defaults.fallback.terminal_win_cmd to route runInTerminal into its
    -- console element — which is NOT in the layout above, so bashdb/js-debug
    -- terminals ended up in an invisible buffer. Re-point it to a real
    -- bottom split so every integrated terminal is visible and interactive,
    -- matching the Go dlv split. (Must run AFTER dapui.setup.)
    dap.defaults.fallback.terminal_win_cmd = require("config.debugging").term_cmd

    -- Colourful per-panel separators so each dap-ui pane stands out
    local dapui_border_colors = {
      dapui_scopes      = "#61afef", -- blue
      dapui_breakpoints = "#e06c75", -- red
      dapui_stacks      = "#d19a66", -- orange
      dapui_watches     = "#c678dd", -- purple
      dapui_console     = "#56b6c2", -- cyan
      dapui_repl        = "#98c379", -- green
    }

    for ft, color in pairs(dapui_border_colors) do
      vim.api.nvim_set_hl(0, "DapUIWinSeparator_" .. ft, { fg = color })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = vim.tbl_keys(dapui_border_colors),
      callback = function(args)
        local win = vim.fn.bufwinid(args.buf)
        vim.wo[win].winhighlight = "WinSeparator:DapUIWinSeparator_" .. args.match
        -- Use solid blocks instead of thin lines so separators stay visible
        -- against a transparent terminal background
        vim.wo[win].fillchars = "vert:█,horiz:▄,horizup:█,horizdown:█,vertleft:█,vertright:█,verthoriz:█"
      end,
    })

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
      vim.notify("Debug session started", vim.log.levels.INFO)
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
      vim.notify("Debug session ended", vim.log.levels.INFO)
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
      vim.notify("Debug session exited", vim.log.levels.INFO)
    end
  end,
}
