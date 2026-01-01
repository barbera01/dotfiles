return {
  "mfussenegger/nvim-dap-python",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  ft = "python",
  config = function()
    local dap_python = require("dap-python")

    -- Set up debugpy path - Mason installs it here
    local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

    dap_python.setup(debugpy_path)

    -- Add custom configurations
    table.insert(require("dap").configurations.python, {
      type = "python",
      request = "launch",
      name = "Launch file with arguments",
      program = "${file}",
      args = function()
        local args_string = vim.fn.input("Arguments: ")
        return vim.split(args_string, " ")
      end,
      pythonPath = function()
        local venv = vim.env.VIRTUAL_ENV
        if venv then
          return venv .. "/bin/python"
        end
        return "/opt/homebrew/bin/python3"
      end,
    })
  end,
}
