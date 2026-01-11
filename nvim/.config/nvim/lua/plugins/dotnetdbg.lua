return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    dap.adapters.coreclr = {
      type = "executable",
      command = "/home/andy/netcoredbg/netcoredbg/netcoredbg",

      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch - netcoredbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/test/bin/Debug/net8.0/test.dll", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = false,

        console = "internalConsole",
      },
    }
  end,
}
