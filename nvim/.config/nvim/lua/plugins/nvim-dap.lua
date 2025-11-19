return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    -- === PowerShell Configuration ===
    -- Note: PowerShell debugging in nvim-dap is limited. Consider using VS Code for full PowerShell debugging.
    -- This configuration will disable PowerShell DAP for now.
    -- Uncomment and configure properly if you have a working PowerShell debug adapter.
    
    -- dap.adapters.powershell = {
    --   type = "executable",
    --   command = "pwsh",
    --   args = { "-Command", "-" }
    -- }
    
    -- dap.configurations.ps1 = {
    --   {
    --     type = "powershell",
    --     request = "launch",
    --     name = "Launch PowerShell script",
    --     script = "${file}",
    --     cwd = "${workspaceFolder}",
    --   },
    -- }

    -- === Go Configuration ===
    dap.adapters.go = {

      type = "server",
      port = "${port}",
      executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
      },
    }

    dap.configurations.go = {
      {
        type = "go",
        name = "Debug Current File",
        request = "launch",
        program = "${file}",
      },
      {

        type = "go",
        name = "Debug Package",
        request = "launch",
        program = "./${relativeFileDirname}",
      },

      {
        type = "go",
        name = "Attach to Process",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
      {
        type = "go",
        name = "Test Current File",
        request = "launch",
        mode = "test",
        program = "${file}",
      },
      {
        type = "go",
        name = "Test Package",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
      },
    }

    -- === Bash Configuration ===
    dap.adapters.bashdb = {
      type = "executable",
      command = "node",
      args = { vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/out/bashDebug.js" },
    }

    dap.configurations.sh = {
      {
        type = "bashdb",
        request = "launch",
        name = "Launch Bash script",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/opt/homebrew/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        env = {},
        terminalKind = "integrated",
      },
      {
        type = "bashdb",
        request = "launch", 
        name = "Launch Bash script with args",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/opt/homebrew/bin/bash",
        pathMkfifo = "mkfifo", 
        pathPkill = "pkill",
        args = function()
          return vim.split(vim.fn.input("Arguments: ", ""), " ")
        end,
        env = {},
        terminalKind = "integrated",
      },
    }

  end,
}
