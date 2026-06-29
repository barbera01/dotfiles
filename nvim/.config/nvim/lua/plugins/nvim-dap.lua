return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    
    -- Configure how DAP opens integrated terminals
    dap.defaults.fallback.external_terminal = {
      command = '/usr/bin/env';
      args = {'bash'};
    }
    
    dap.defaults.fallback.force_external_terminal = false

    -- Modern DAP signs with better icons (from dap-styling)
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

    -- Modern highlight groups for DAP
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
      display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == 'inline' then
          return ' = ' .. variable.value
        else
          return variable.name .. ' = ' .. variable.value
        end
      end,
      virt_text_pos = 'eol',
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

    -- === PowerShell Configuration (via PowerShell Editor Services) ===
    local pses_bundle = vim.fn.expand("~/.local/share/nvim/dap-adapters/powershell-es")
    local pses_script = pses_bundle .. "/PowerShellEditorServices/Start-EditorServices.ps1"

    dap.adapters.powershell = {
      type = "pipe",
      pipe = "${pipe}",
      executable = {
        command = "pwsh",
        args = {
          "-NoLogo",
          "-NoProfile",
          pses_script,
          "-BundledModulesPath", pses_bundle,
          "-SessionDetailsPath", pses_bundle .. "/session.json",
          "-LogPath", pses_bundle .. "/logs.log",
          "-LogLevel", "Normal",
          "-DebugServiceOnly",
          "-DebugServicePipeName", "${pipe}",
        },
      },
    }

    local powershell_config = {
      {
        type = "powershell",
        request = "launch",
        name = "Launch PowerShell Script",
        script = "${file}",
        cwd = "${workspaceFolder}",
      },
      {
        type = "powershell",
        request = "launch",
        name = "Launch PowerShell Script (with args)",
        script = "${file}",
        cwd = "${workspaceFolder}",
        args = function()
          local input = vim.fn.input("Arguments: ")
          return vim.split(input, " ", { trimempty = true })
        end,
      },
    }

    dap.configurations.ps1 = powershell_config
    dap.configurations.powershell = powershell_config
    dap.configurations.psm1 = powershell_config

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
        showDebugOutput = false,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = false,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/usr/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        argsString = "",
        env = {},
        terminalKind = "integrated",
      },
      {
        type = "bashdb",
        request = "launch",
        name = "Launch Bash script with args",
        showDebugOutput = false,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = false,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/usr/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        argsString = function()
          return vim.fn.input("Arguments: ", "")
        end,
        env = {},
        terminalKind = "integrated",
      },
      {
        type = "bashdb",
        request = "launch",
        name = "Debug: update-service-connection (argsString)",
        showDebugOutput = false,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = false,
        file = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
        program = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/usr/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        argsString = '--connection-name "Dev-Pipelines" --project "terramate" --org "https://dev.azure.com/ADVW" --debug',
        env = {
          AZURE_DEVOPS_EXT_PAT = vim.fn.getenv("AZURE_DEVOPS_EXT_PAT") or ""
        },
        terminalKind = "integrated",
      },
      {
        type = "bashdb",
        request = "launch",
        name = "Debug: update-service-connection (args array)",
        showDebugOutput = false,
        pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = false,
        file = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
        program = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/usr/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = { "--connection-name", "Dev-Pipelines", "--project", "terramate", "--org", "https://dev.azure.com/ADVW" },
        argsString = "",
        env = {
          AZURE_DEVOPS_EXT_PAT = vim.fn.getenv("AZURE_DEVOPS_EXT_PAT") or ""
        },
        terminalKind = "integrated",
      },
    }


    -- === JavaScript/TypeScript Configuration ===
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      }
    }

    -- JavaScript configurations
    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
        outputCapture = "console",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require'dap.utils'.pick_process,
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**" },
      }
    }

    -- Copy configuration for JSX files
    dap.configurations.javascriptreact = dap.configurations.javascript

    -- TypeScript configurations
    dap.configurations.typescript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch TypeScript file (tsx)",
        program = "${file}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        sourceMaps = true,
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**"
        },
        skipFiles = { "<node_internals>/**" },
        outputCapture = "console",
        runtimeExecutable = vim.fn.exepath("tsx"),
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch TypeScript file (ts-node)",
        program = "${file}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        sourceMaps = true,
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**"
        },
        skipFiles = { "<node_internals>/**" },
        outputCapture = "console",
        runtimeExecutable = vim.fn.exepath("node"),
        runtimeArgs = { "--loader", "ts-node/esm" },
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach to TypeScript process",
        processId = require'dap.utils'.pick_process,
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**" },
        sourceMaps = true,
      }
    }

    -- Copy configuration for TSX files
    dap.configurations.typescriptreact = dap.configurations.typescript

  end,
}
