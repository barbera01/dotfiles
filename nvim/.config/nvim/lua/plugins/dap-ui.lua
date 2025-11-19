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
        max_type_length = 50,
        max_value_lines = 200,
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
      
      -- Expand lines by default
      expand_lines = true,
      
      -- Force winbar
      force_buffers = true,
    })

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