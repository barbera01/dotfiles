return {
  "rcarriga/nvim-dap-ui",
  dependencies = { 
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    
    -- Cool modern DAP UI configuration
    dapui.setup({
      -- Modern icons
      icons = { 
        expanded = "󰅀", 
        collapsed = "󰅂", 
        current_frame = "󰁔"
      },
      
      -- Custom mappings
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      
      -- Add borders to all windows
      element_mappings = {},
      
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      
      force_buffers = true,
      
      -- Sleek layout with better proportions
      layouts = {
        {
          -- Primary debugging sidebar
          elements = {
            {
              id = "scopes",
              size = 0.50, -- 50% - main variable inspection
            },
            {
              id = "watches", 
              size = 0.25, -- 25% - custom watches
            },
            {
              id = "breakpoints",
              size = 0.15, -- 15% - breakpoint list
            },
            {
              id = "stacks",
              size = 0.10, -- 10% - call stack (compact)
            },
          },
          size = 60, -- Wider sidebar for better readability
          position = "left",
        },
        {
          -- Bottom console area - stacked vertically
          elements = {
            {
              id = "console",
              size = 0.7, -- 70% for stdout/stderr console output (top)
            },
            {
              id = "repl",
              size = 0.3, -- 30% for REPL commands (bottom)
            },
          },
          size = 30, -- Taller for better vertical stacking
          position = "bottom",
        },
      },
      
      -- Enhanced controls
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "󰏤",
          play = "󰐊",
          step_into = "󰆹",
          step_over = "󰆷", 
          step_out = "󰆸",
          step_back = "󰕍",
          run_last = "󰑮",
          terminate = "󰝤",
          disconnect = "󰖪",
        },
      },
      
      -- Better rendering
      render = {
        max_type_length = 100,
        max_value_lines = 500, -- Show more lines in console
        indent = 2,
      },
      
      -- Floating windows with modern borders
      floating = {
        max_height = 0.9,
        max_width = 0.9,
        border = "rounded",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      
    })
    
    -- Set clearer border colors for DAP UI windows (white for maximum visibility)
    vim.api.nvim_set_hl(0, "DapUIFloatBorder", { fg = "#ffffff", bold = true })
    vim.api.nvim_set_hl(0, "DapUIWinSelect", { fg = "#ffffff", bold = true })
    
    -- Make window separators more visible (white)
    vim.api.nvim_set_hl(0, "DapUIVertSplit", { fg = "#ffffff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DapUIWinSeparator", { fg = "#ffffff", bg = "NONE" })
    
    -- Make console output more readable
    vim.api.nvim_set_hl(0, "DapUIConsole", { fg = "#d4d4d4" })
    vim.api.nvim_set_hl(0, "DapUIConsoleInfo", { fg = "#4ec9b0" })
    vim.api.nvim_set_hl(0, "DapUIConsoleWarning", { fg = "#ffcb6b" })
    vim.api.nvim_set_hl(0, "DapUIConsoleError", { fg = "#f44747" })
    
    -- Additional highlights for better visibility
    vim.api.nvim_set_hl(0, "DapUINormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "DapUINormalNC", { bg = "NONE" })
    
    -- Set global window separator to be more visible during debug sessions
    local original_winhighlight = vim.wo.winhighlight
    dap.listeners.after.event_initialized["set_winhl"] = function()
      vim.opt.fillchars:append({ vert = "│", horiz = "─", horizup = "┴", horizdown = "┬", vertleft = "┤", vertright = "├", verthoriz = "┼" })
    end
    
    dap.listeners.before.event_terminated["restore_winhl"] = function()
      vim.opt.fillchars = vim.opt.fillchars
    end

    -- Enhanced auto-open/close with better UX
    local dapui_group = vim.api.nvim_create_augroup("DapuiConfig", { clear = true })
    
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
      vim.notify("🐛 Debug session started", vim.log.levels.INFO)
    end
    
    dap.listeners.before.event_terminated["dapui_config"] = function()
      vim.notify("🏁 Debug session ended", vim.log.levels.INFO)
      vim.defer_fn(function()
        dapui.close()
      end, 100)
    end
    
    dap.listeners.before.event_exited["dapui_config"] = function()
      vim.notify("👋 Debug session exited", vim.log.levels.INFO)
      vim.defer_fn(function()
        dapui.close()
      end, 100)
    end

    -- Cool keymaps with better descriptions
    -- Note: <leader>dc is reserved for DAP continue in keymaps.lua
    vim.keymap.set("n", "<leader>du", function()
      dapui.toggle()
    end, { desc = "🎛️  Toggle Debug UI" })
    
    vim.keymap.set("n", "<leader>dr", function()
      dapui.toggle({ layout = 2 }) -- Toggle bottom panel with REPL + Console
    end, { desc = "💬 Toggle Debug REPL + Console" })
    
    vim.keymap.set("n", "<leader>dC", function()
      dapui.open({ layout = 2 }) -- Open bottom console panel
      vim.cmd("wincmd j") -- Jump to bottom window
    end, { desc = "📺 Open Debug Console (Shift+C)" })
    
    vim.keymap.set("n", "<leader>do", function()
      dapui.float_element("console", { 
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.9),
        enter = true,
      })
    end, { desc = "📺 Float Console Output (large)" })
    
    vim.keymap.set("n", "<leader>de", function()
      dapui.eval()
    end, { desc = "🔍 Evaluate Expression" })
    
    vim.keymap.set("v", "<leader>de", function()
      dapui.eval()
    end, { desc = "🔍 Evaluate Selection" })
    
    vim.keymap.set("n", "<leader>df", function()
      dapui.float_element()
    end, { desc = "🪟 Float Debug Element" })
    
    vim.keymap.set("n", "<leader>dh", function()
      require('dap.ui.widgets').hover()
    end, { desc = "📋 Debug Hover Info" })
    
    -- Reset layout if it gets messed up
    vim.keymap.set("n", "<leader>dR", function()
      dapui.close()
      vim.defer_fn(function()
        dapui.open()
      end, 100)
    end, { desc = "🔄 Reset Debug Layout" })
  end,
}