-- DAP adapters + configurations for Go / Bash / JS-TS. Shared behaviour
-- (bottom-terminal contract, switchbuf, orphan cleanup) is in
-- lua/config/debugging.lua; UI layout in lua/plugins/dap-ui.lua; PowerShell
-- in lua/plugins/powershell.lua; all keymaps in lua/config/keymaps.lua.
return {
  -- LazyVim's lang.go extra injects nvim-dap-go, whose setup() replaces our
  -- dap.adapters.go — which must also handle attach+remote for the
  -- interactive-terminal flow (<leader>dd/<leader>dg). Keep it disabled;
  -- Go is fully configured below.
  { "leoluz/nvim-dap-go", enabled = false },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mxsdev/nvim-dap-vscode-js",
        build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
        config = function()
          require("dap-vscode-js").setup({
            node_path = "node",
            debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
            adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
          })
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = true,
          show_stop_reason = true,
          commented = false,
          only_first_definition = true,
          all_references = false,
          clear_on_continue = false,
          virt_text_pos = "eol",
          all_frames = false,
          virt_lines = false,
        },
      },
    },
    config = function()
      local dap = require("dap")

      -- === Visuals / Signs ===
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "DapBreakpointLine", numhl = "DapBreakpointNum" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◉", texthl = "DapBreakpointCondition", linehl = "DapBreakpointLine", numhl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected", numhl = "DapBreakpointRejected" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", numhl = "DapLogPoint" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "DapStoppedNum" })

      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75", bold = true })
      vim.api.nvim_set_hl(0, "DapBreakpointNum", { fg = "#e06c75", bold = true })
      vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#3d2a2e" })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b", bold = true })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#5c6370", italic = true })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#56b6c2", bold = true })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bold = true })
      vim.api.nvim_set_hl(0, "DapStoppedNum", { fg = "#98c379", bold = true })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2c3325" })

      -- Shared behaviour: source-window placement on stop, pwsh debug
      -- terminal placement, orphaned-debuggee cleanup.
      require("config.debugging").setup(dap)

      -- === Go ===
      -- The adapter handles BOTH cases:
      --   * launch        -> spawn `dlv dap` (fine for non-interactive programs)
      --   * attach+remote -> connect to a headless dlv that is already running
      --     (used by the interactive flow in config/debugging.lua)
      dap.adapters.go = function(callback, config)
        if config.request == "attach" and config.mode == "remote" then
          callback({ type = "server", host = config.host or "127.0.0.1", port = config.port })
        else
          callback({
            type = "server",
            port = "${port}",
            executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
          })
        end
      end

      dap.configurations.go = {
        -- Non-interactive launches (no stdin). Output is captured by dap; for
        -- programs that read stdin use the interactive launcher (<leader>dd).
        { type = "go", name = "Debug Current File", request = "launch", program = "${file}" },
        { type = "go", name = "Debug Package",      request = "launch", program = "./${relativeFileDirname}" },
        { type = "go", name = "Test Current File",  request = "launch", mode = "test", program = "${file}" },
        { type = "go", name = "Test Package",       request = "launch", mode = "test", program = "./${relativeFileDirname}" },
        { type = "go", name = "Attach to Process",  request = "attach", processId = require("dap.utils").pick_process },
      }

      -- === Bash ===
      -- bashdb runs the script via a runInTerminal request; with
      -- terminalKind="integrated" nvim-dap opens it through
      -- dap.defaults.fallback.terminal_win_cmd (re-pointed to the bottom
      -- split in dap-ui.lua), so stdin/stdout are fully interactive.
      local bash_ext = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension"
      dap.adapters.bashdb = {
        type = "executable",
        command = "node",
        args = { bash_ext .. "/out/bashDebug.js" },
      }

      local function bashdb(overrides)
        return vim.tbl_extend("force", {
          type = "bashdb",
          request = "launch",
          showDebugOutput = false,
          trace = false,
          pathBashdb = bash_ext .. "/bashdb_dir/bashdb",
          pathBashdbLib = bash_ext .. "/bashdb_dir",
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
        }, overrides)
      end

      dap.configurations.sh = {
        bashdb({ name = "Launch Bash script" }),
        bashdb({
          name = "Launch Bash script with args",
          argsString = function()
            return vim.fn.input("Arguments: ", "")
          end,
        }),
        -- Project-specific: terramate service-connection helper script.
        bashdb({
          name = "Debug: update-service-connection (argsString)",
          file = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
          program = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
          argsString = '--connection-name "Dev-Pipelines" --project "terramate" --org "https://dev.azure.com/ADVW" --debug',
          env = { AZURE_DEVOPS_EXT_PAT = vim.fn.getenv("AZURE_DEVOPS_EXT_PAT") or "" },
        }),
        bashdb({
          name = "Debug: update-service-connection (args array)",
          file = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
          program = "${workspaceFolder}/support-scripts/update-service-connection-description.sh",
          args = { "--connection-name", "Dev-Pipelines", "--project", "terramate", "--org", "https://dev.azure.com/ADVW" },
          env = { AZURE_DEVOPS_EXT_PAT = vim.fn.getenv("AZURE_DEVOPS_EXT_PAT") or "" },
        }),
      }
      dap.configurations.bash = dap.configurations.sh

      -- === JavaScript / TypeScript / Vue ===
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
        },
      }

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
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          skipFiles = { "<node_internals>/**" },
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome (Vite)",
          url = "http://localhost:3000",
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
          skipFiles = { "<node_internals>/**", "node_modules/**" },
        },
        {
          type = "pwa-chrome",
          request = "attach",
          name = "Attach to Chrome",
          port = 9222,
          webRoot = "${workspaceFolder}/src",
        },
      }

      dap.configurations.javascriptreact = dap.configurations.javascript
      dap.configurations.typescript = dap.configurations.javascript
      dap.configurations.typescriptreact = dap.configurations.javascript
      dap.configurations.vue = dap.configurations.javascript

      -- PowerShell is owned by powershell.nvim (lua/plugins/powershell.lua):
      -- PSES with a real console REPL in a terminal buffer registers the
      -- "ps1" adapter and its launch/attach configurations itself.
    end,
  },
}
