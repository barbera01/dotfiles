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
      -- left free for the interactive dlv terminal opened by <leader>dg, so the
      -- two don't fight (that overlap was the "UI mess"). The repl/console can
      -- still be floated on demand: <leader>dfc (console) / <leader>dfr (repl).
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.50 },
            { id = "watches",     size = 0.25 },
            { id = "breakpoints", size = 0.15 },
            { id = "stacks",      size = 0.10 },
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

    local function focus_dap_console()
      dapui.open({ layout = 2 })

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        local ft = vim.bo[buf].filetype

        if ft == "dapui_console" or name:match("DAP Console") then
          vim.api.nvim_set_current_win(win)
          vim.cmd("normal! G")
          return
        end
      end

      vim.notify("DAP console is not open yet", vim.log.levels.WARN)
    end

    vim.keymap.set("n", "<leader>du", function() dapui.toggle() end,                    { desc = "Toggle Debug UI" })
    vim.keymap.set("n", "<leader>de", function() dapui.eval() end,                      { desc = "Evaluate Expression" })
    vim.keymap.set("v", "<leader>de", function() dapui.eval() end,                      { desc = "Evaluate Selection" })
    vim.keymap.set("n", "<leader>df", function() dapui.float_element() end,             { desc = "Float Debug Element" })
    vim.keymap.set("n", "<leader>dt", focus_dap_console,                                { desc = "Focus Debug Terminal" })
    -- NB: <leader>dc is DAP Continue (config/keymaps.lua). Float-console moved to
    -- <leader>dfc so it no longer shadows Continue (that shadowing made debug
    -- sessions look frozen — the program never continued past entry).
    vim.keymap.set("n", "<leader>dfc", function() dapui.float_element("console") end,   { desc = "Float Debug Console" })
    vim.keymap.set("n", "<leader>dfr", function() dapui.float_element("repl") end,      { desc = "Float Debug REPL" })
    vim.keymap.set("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debug Hover Info" })
    vim.keymap.set("n", "<leader>dR", function()
      dapui.close()
      vim.defer_fn(function() dapui.open() end, 100)
    end, { desc = "Reset Debug Layout" })
  end,
}
