-- PowerShell Debugging Helper Functions
-- Add these to your config for easy PowerShell debugging

-- Quick command to open PowerShell debugging terminal
vim.api.nvim_create_user_command('PsDebug', function()
  local current_file = vim.fn.expand('%:p')
  local file_dir = vim.fn.expand('%:p:h')
  local file_name = vim.fn.expand('%:t')
  
  -- Open split and terminal
  vim.cmd('split')
  vim.cmd('terminal')
  vim.cmd('startinsert')
  
  -- Send commands to terminal (after a short delay)
  vim.defer_fn(function()
    local term_buf = vim.api.nvim_get_current_buf()
    local chan_id = vim.b.terminal_job_id
    
    if chan_id then
      -- Navigate to script directory
      vim.api.nvim_chan_send(chan_id, string.format('cd "%s"\r', file_dir))
      vim.fn.wait(100)
      
      -- Start pwsh
      vim.api.nvim_chan_send(chan_id, 'pwsh\r')
      vim.fn.wait(200)
      
      -- Show helpful message
      vim.api.nvim_chan_send(chan_id, string.format(
        'Write-Host "PowerShell Debugger Ready! " -ForegroundColor Green\r' ..
        'Write-Host "Set breakpoint: Set-PSBreakpoint -Script ./%s -Line 10" -ForegroundColor Yellow\r' ..
        'Write-Host "Run script: ./%s" -ForegroundColor Yellow\r' ..
        'Write-Host "Debug commands: s (step), v (step over), c (continue), q (quit)" -ForegroundColor Cyan\r',
        file_name, file_name
      ))
    end
  end, 500)
end, { desc = "Open PowerShell debugging terminal" })

-- Command to quickly set a PowerShell breakpoint at current line
vim.api.nvim_create_user_command('PsBreakpoint', function()
  local current_file = vim.fn.expand('%:t')
  local current_line = vim.fn.line('.')
  
  -- Copy breakpoint command to clipboard
  local bp_command = string.format('Set-PSBreakpoint -Script ./%s -Line %d', current_file, current_line)
  vim.fn.setreg('+', bp_command)
  
  vim.notify(
    string.format('Breakpoint command copied to clipboard!\n%s', bp_command),
    vim.log.levels.INFO
  )
end, { desc = "Copy PowerShell breakpoint command" })

-- Keybindings (add to your keymaps)
vim.keymap.set('n', '<leader>pd', ':PsDebug<CR>', { 
  desc = "PowerShell Debug Terminal",
  silent = true 
})

vim.keymap.set('n', '<leader>pb', ':PsBreakpoint<CR>', { 
  desc = "Copy PowerShell Breakpoint",
  silent = true 
})

-- Auto-command to show PowerShell debugging help on .ps1 files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ps1',
  callback = function()
    -- Optional: Show a message when opening PS1 files
    vim.defer_fn(function()
      vim.notify(
        '💡 PowerShell Debugging:\n' ..
        '  <leader>pd - Open debug terminal\n' ..
        '  <leader>pb - Copy breakpoint command\n' ..
        '  Or use: :PsDebug',
        vim.log.levels.INFO
      )
    end, 1000)
  end
})
