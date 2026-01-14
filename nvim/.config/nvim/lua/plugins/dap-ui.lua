return {
  "rcarriga/nvim-dap-ui",
  dependencies = { 
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    
    -- Cool modern DAP UI configuration with enhanced visuals
    dapui.setup({
      -- Modern icons with better visual hierarchy
      icons = { 
        expanded = "▾", 
        collapsed = "▸", 
        current_frame = "→"
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
      
      -- Element mappings for better navigation
      element_mappings = {},
      
      -- Sleek layout with better proportions
      -- Using RIGHT position to avoid conflicts with file explorer on the left
      layouts = {
        {
          -- Primary debugging sidebar (on the right to not conflict with explorer)
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
          position = "right", -- Right side to keep explorer on the left
        },
        {
          -- Bottom console area
          elements = {
            {
              id = "console",
              size = 1.0, -- Full bottom panel for output
            },
          },
          size = 15, -- Taller console for better visibility
          position = "bottom",
        },
        {
          -- Floating REPL (activated separately)
          elements = {
            {
              id = "repl",
              size = 1.0,
            },
          },
          size = 0.3,
          position = "bottom",
        },
      },
      
      -- Enhanced controls with beautiful modern icons
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⤵",
          step_over = "⤴", 
          step_out = "⤴",
          step_back = "⏮",
          run_last = "↻",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
      
      -- Better rendering
      render = {
        max_type_length = 50,
        max_value_lines = 200,
        indent = 2,
      },
      
      -- Floating windows with modern borders and transparency
      floating = {
        max_height = 0.9,
        max_width = 0.9,
        border = "rounded", -- "single" | "double" | "rounded" | "solid" | "shadow"
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      
      -- Window configuration for better visuals
      windows = { 
        indent = 1 
      },
      
      -- Expand lines by default
      expand_lines = true,
      
      -- Force winbar
      force_buffers = true,
    })

    -- Auto-open DAP UI when debugging starts
    -- DAP UI will stay open after debugging ends (manual close with <leader>du)
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
      vim.notify("🐛 Debug session started", vim.log.levels.INFO)
    end
    
    -- Notify when debugging ends, but keep UI open for inspection
    dap.listeners.before.event_terminated["dapui_config"] = function()
      vim.notify("🏁 Debug session ended - UI still open for inspection", vim.log.levels.INFO)
      -- UI stays open - close manually with <leader>du if needed
    end
    
    dap.listeners.before.event_exited["dapui_config"] = function()
      vim.notify("👋 Debug session exited - UI still open for inspection", vim.log.levels.INFO)
      -- UI stays open - close manually with <leader>du if needed
    end

    -- Cool keymaps with better descriptions
    vim.keymap.set("n", "<leader>du", function()
      dapui.toggle()
    end, { desc = "🎛️  Toggle Debug UI" })
    
    vim.keymap.set("n", "<leader>dr", function()
      dapui.toggle({ layout = 3 }) -- Toggle REPL
    end, { desc = "💬 Toggle Debug REPL" })
    
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