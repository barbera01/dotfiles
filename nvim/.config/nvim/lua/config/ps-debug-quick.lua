-- PowerShell Debugging Helper - Quick Access
-- Add this to your init.lua or require it from another config file

-- Command to open PowerShell debugging terminal with helpful instructions
vim.api.nvim_create_user_command('PsDebug', function()
  local current_file = vim.fn.expand('%:t')
  
  -- Open split terminal
  vim.cmd('split')
  vim.cmd('resize 20')  -- Make it reasonably sized
  vim.cmd('terminal')
  
  -- Wait a bit then send helpful commands
  vim.defer_fn(function()
    local chan_id = vim.b.terminal_job_id
    if chan_id then
      -- Start pwsh
      vim.api.nvim_chan_send(chan_id, 'pwsh\r')
      
      -- Wait a bit for pwsh to start
      vim.defer_fn(function()
        -- Send helpful message
        vim.api.nvim_chan_send(chan_id, 'Write-Host ""\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "  PowerShell Debugger Ready!" -ForegroundColor Green\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host ""\r')
        vim.api.nvim_chan_send(chan_id, string.format('Write-Host "📍 Current file: %s" -ForegroundColor Yellow\r', current_file))
        vim.api.nvim_chan_send(chan_id, 'Write-Host ""\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "Quick Start:" -ForegroundColor Cyan\r')
        vim.api.nvim_chan_send(chan_id, string.format('Write-Host "  1. Set-PSBreakpoint -Script ./%s -Line 10" -ForegroundColor White\r', current_file))
        vim.api.nvim_chan_send(chan_id, string.format('Write-Host "  2. ./%s" -ForegroundColor White\r', current_file))
        vim.api.nvim_chan_send(chan_id, 'Write-Host ""\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "Debug Commands:" -ForegroundColor Cyan\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "  s - Step into  |  v - Step over  |  c - Continue  |  q - Quit" -ForegroundColor White\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host ""\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray\r')
        vim.api.nvim_chan_send(chan_id, 'Write-Host ""\r')
      end, 1000)
    end
  end, 100)
  
  -- Enter insert mode so you can type immediately (after the messages)
  vim.defer_fn(function()
    vim.cmd('startinsert')
  end, 2000)
end, { 
  desc = "Open PowerShell debugging terminal" 
})

-- Add convenient keymap
vim.keymap.set('n', '<leader>pd', ':PsDebug<CR>', { 
  desc = "PowerShell Debug Terminal",
  silent = true 
})

-- Show hint when opening PowerShell files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ps1',
  callback = function()
    -- Only show once per session
    if not vim.g.ps1_debug_hint_shown then
      vim.g.ps1_debug_hint_shown = true
      vim.defer_fn(function()
        print("💡 PowerShell debugging: Use :PsDebug or <leader>pd")
      end, 500)
    end
  end
})
