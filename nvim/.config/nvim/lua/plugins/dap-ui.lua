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
        {
          elements = {
            -- For Go/Delve, program stdout/stderr is most useful in the
            -- terminal pane. The console pane is often empty because it only
            -- shows DAP adapter output/events, not normal fmt.Println output.
            { id = "console",  size = 0.10 },
            { id = "repl",     size = 0.25 },
            { id = "terminal", size = 0.65 },
          },
          size = 18,
          position = "bottom",
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
    vim.keymap.set("n", "<leader>dc", function() dapui.float_element("console") end,    { desc = "Float Debug Console" })
    vim.keymap.set("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debug Hover Info" })
    vim.keymap.set("n", "<leader>dR", function()
      dapui.close()
      vim.defer_fn(function() dapui.open() end, 100)
    end, { desc = "Reset Debug Layout" })
  end,
}
