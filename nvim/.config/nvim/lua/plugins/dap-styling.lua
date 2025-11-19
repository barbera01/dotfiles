return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui"
  },
  config = function()
    local dap = require("dap")
    
    -- Modern DAP signs with better icons
    vim.fn.sign_define("DapBreakpoint", {
      text = "󰝥",
      texthl = "DapBreakpoint", 
      linehl = "DapBreakpointLine",
      numhl = "DapBreakpointNum"
    })
    
    vim.fn.sign_define("DapBreakpointCondition", {
      text = "◆",
      texthl = "DapBreakpointCondition", 
      linehl = "",
      numhl = "DapBreakpointCondition"
    })
    
    vim.fn.sign_define("DapBreakpointRejected", {
      text = "○",
      texthl = "DapBreakpointRejected",
      linehl = "",
      numhl = "DapBreakpointRejected"
    })
    
    vim.fn.sign_define("DapLogPoint", {
      text = "◇",
      texthl = "DapLogPoint",
      linehl = "",
      numhl = "DapLogPoint"
    })
    
    vim.fn.sign_define("DapStopped", {
      text = "󰁔",
      texthl = "DapStopped",
      linehl = "DapStoppedLine", 
      numhl = "DapStoppedNum"
    })

    -- Modern highlight groups for DAP with better colors
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff6b6b", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointNum", { fg = "#ff6b6b" })
    vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#2d1b2b" })
    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ffa500", bold = true })
    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#6c757d" })
    vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#4ecdc4", bold = true })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#51cf66", bold = true })
    vim.api.nvim_set_hl(0, "DapStoppedNum", { fg = "#51cf66", bold = true })
    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#1a2b1a", bold = true })

    -- Virtual text configuration
    require("nvim-dap-virtual-text").setup({
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      clear_on_continue = false,
      
      -- Virtual text display options
      display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == 'inline' then
          return ' = ' .. variable.value
        else
          return variable.name .. ' = ' .. variable.value
        end
      end,
      
      -- Virtual text position
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align' | 'inline'
      
      -- Virtual text formatting
      all_frames = false,
      virt_lines = false,
      virt_text_win_col = nil
    })

    -- Enhanced DAP UI colors and styling
    vim.api.nvim_set_hl(0, "DapUIVariable", { fg = "#d4d4d4" })
    vim.api.nvim_set_hl(0, "DapUIScope", { fg = "#00d7ff" }) 
    vim.api.nvim_set_hl(0, "DapUIType", { fg = "#d4d4d4" })
    vim.api.nvim_set_hl(0, "DapUIValue", { fg = "#99c794" })
    vim.api.nvim_set_hl(0, "DapUIModifiedValue", { fg = "#ffcb6b", bold = true })
    vim.api.nvim_set_hl(0, "DapUIDecoration", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIThread", { fg = "#c3e88d" })
    vim.api.nvim_set_hl(0, "DapUIStoppedThread", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIFrameName", { fg = "#d4d4d4" })
    vim.api.nvim_set_hl(0, "DapUISource", { fg = "#d4d4d4" })
    vim.api.nvim_set_hl(0, "DapUILineNumber", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIFloatBorder", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIWatchesEmpty", { fg = "#f07178" })
    vim.api.nvim_set_hl(0, "DapUIWatchesValue", { fg = "#c3e88d" })
    vim.api.nvim_set_hl(0, "DapUIWatchesError", { fg = "#f07178" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsPath", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsInfo", { fg = "#c3e88d" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsCurrentLine", { fg = "#c3e88d", bold = true })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsLine", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIBreakpointsDisabledLine", { fg = "#848484" })
    vim.api.nvim_set_hl(0, "DapUICurrentFrameName", { fg = "#c3e88d", bold = true })
    vim.api.nvim_set_hl(0, "DapUIStepOver", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIStepInto", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIStepBack", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIStepOut", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIStop", { fg = "#f07178" })
    vim.api.nvim_set_hl(0, "DapUIPlayPause", { fg = "#c3e88d" })
    vim.api.nvim_set_hl(0, "DapUIRestart", { fg = "#c3e88d" })
    vim.api.nvim_set_hl(0, "DapUIUnavailable", { fg = "#848484" })
    vim.api.nvim_set_hl(0, "DapUIWinSelect", { fg = "#00d7ff", bold = true })
    vim.api.nvim_set_hl(0, "DapUIEndCollapseOne", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUIEndCollapse", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUICollapseOne", { fg = "#00d7ff" })
    vim.api.nvim_set_hl(0, "DapUICollapse", { fg = "#00d7ff" })
  end,
}