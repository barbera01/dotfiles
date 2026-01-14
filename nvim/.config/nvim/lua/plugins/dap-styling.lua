return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui"
  },
  config = function()
    local dap = require("dap")
    
    -- Modern DAP signs with beautiful icons
    vim.fn.sign_define("DapBreakpoint", {
      text = "●",
      texthl = "DapBreakpoint", 
      linehl = "DapBreakpointLine",
      numhl = "DapBreakpointNum"
    })
    
    vim.fn.sign_define("DapBreakpointCondition", {
      text = "◉",
      texthl = "DapBreakpointCondition", 
      linehl = "DapBreakpointLine",
      numhl = "DapBreakpointCondition"
    })
    
    vim.fn.sign_define("DapBreakpointRejected", {
      text = "○",
      texthl = "DapBreakpointRejected",
      linehl = "",
      numhl = "DapBreakpointRejected"
    })
    
    vim.fn.sign_define("DapLogPoint", {
      text = "◆",
      texthl = "DapLogPoint",
      linehl = "",
      numhl = "DapLogPoint"
    })
    
    vim.fn.sign_define("DapStopped", {
      text = "▶",
      texthl = "DapStopped",
      linehl = "DapStoppedLine", 
      numhl = "DapStoppedNum"
    })

    -- Modern highlight groups for DAP with vibrant colors
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointNum", { fg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#3d2a2e" })
    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#5c6370", italic = true })
    vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#56b6c2", bold = true })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapStoppedNum", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2c3325" })

    -- Virtual text configuration with beautiful formatting
    require("nvim-dap-virtual-text").setup({
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = true,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      clear_on_continue = false,
      
      -- Virtual text display with nice formatting
      display_callback = function(variable, buf, stackframe, node, options)
        -- Truncate long values
        local value = variable.value
        local max_len = 50
        if #value > max_len then
          value = string.sub(value, 1, max_len) .. "..."
        end
        
        if options.virt_text_pos == 'inline' then
          return ' ← ' .. value
        else
          return '  ' .. variable.name .. ' = ' .. value
        end
      end,
      
      -- Virtual text position
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align' | 'inline'
      
      -- Virtual text formatting
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil,
    })
    
    -- Virtual text highlight
    vim.api.nvim_set_hl(0, "NvimDapVirtualText", { fg = "#56b6c2", italic = true })
    vim.api.nvim_set_hl(0, "NvimDapVirtualTextChanged", { fg = "#e5c07b", italic = true, bold = true })

    -- Enhanced DAP UI colors with modern palette
    -- Variables and values
    vim.api.nvim_set_hl(0, "DapUIVariable", { fg = "#abb2bf" })
    vim.api.nvim_set_hl(0, "DapUIScope", { fg = "#61afef", bold = true }) 
    vim.api.nvim_set_hl(0, "DapUIType", { fg = "#c678dd", italic = true })
    vim.api.nvim_set_hl(0, "DapUIValue", { fg = "#98c379" })
    vim.api.nvim_set_hl(0, "DapUIModifiedValue", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "DapUIDecoration", { fg = "#61afef" })
    
    -- Threads and frames
    vim.api.nvim_set_hl(0, "DapUIThread", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapUIStoppedThread", { fg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "DapUIFrameName", { fg = "#abb2bf" })
    vim.api.nvim_set_hl(0, "DapUICurrentFrameName", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapUISource", { fg = "#56b6c2", italic = true })
    vim.api.nvim_set_hl(0, "DapUILineNumber", { fg = "#61afef" })
    
    -- Borders and UI elements
    vim.api.nvim_set_hl(0, "DapUIFloatBorder", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "DapUIFloatNormal", { bg = "#1e222a" })
    vim.api.nvim_set_hl(0, "DapUINormal", { bg = "#1e222a" })
    vim.api.nvim_set_hl(0, "DapUINormalNC", { bg = "#1e222a" })
    
    -- Watches
    vim.api.nvim_set_hl(0, "DapUIWatchesEmpty", { fg = "#5c6370", italic = true })
    vim.api.nvim_set_hl(0, "DapUIWatchesValue", { fg = "#98c379" })
    vim.api.nvim_set_hl(0, "DapUIWatchesError", { fg = "#e06c75" })
    
    -- Breakpoints
    vim.api.nvim_set_hl(0, "DapUIBreakpointsPath", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsInfo", { fg = "#98c379" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsCurrentLine", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsLine", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsDisabledLine", { fg = "#5c6370", strikethrough = true })
    
    -- Control icons with vibrant colors
    vim.api.nvim_set_hl(0, "DapUIStepOver", { fg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "DapUIStepInto", { fg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "DapUIStepBack", { fg = "#c678dd", bold = true })
    vim.api.nvim_set_hl(0, "DapUIStepOut", { fg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "DapUIStop", { fg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "DapUIPlayPause", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapUIRestart", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "DapUIUnavailable", { fg = "#5c6370", italic = true })
    
    -- Additional control highlights
    vim.api.nvim_set_hl(0, "DapUIPlay", { fg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "DapUIPause", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "DapUITerminate", { fg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "DapUIDisconnect", { fg = "#e06c75", bold = true })
    
    -- Navigation
    vim.api.nvim_set_hl(0, "DapUIWinSelect", { fg = "#61afef", bold = true })
    
    -- Tree/collapse indicators
    vim.api.nvim_set_hl(0, "DapUIEndCollapseOne", { fg = "#56b6c2" })
    vim.api.nvim_set_hl(0, "DapUIEndCollapse", { fg = "#56b6c2" })
    vim.api.nvim_set_hl(0, "DapUICollapseOne", { fg = "#56b6c2" })
    vim.api.nvim_set_hl(0, "DapUICollapse", { fg = "#56b6c2" })
  end,
}