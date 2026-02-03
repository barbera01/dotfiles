return {
  "mfussenegger/nvim-dap",
  init = function()
    local function get_dll_file()
      return vim.fn.getcwd() .. "/.nvim-dap-dll"
    end

    local function load_dll()
      local dll_file = get_dll_file()
      vim.notify("Checking for: " .. dll_file, vim.log.levels.DEBUG)
      if vim.fn.filereadable(dll_file) == 1 then
        local content = vim.fn.readfile(dll_file)[1]
        vim.notify("File content: " .. vim.inspect(content), vim.log.levels.DEBUG)
        if content and content ~= "" then
          vim.g.dotnet_dap_dll = content
          vim.notify("Loaded DLL: " .. content, vim.log.levels.INFO)
          return true
        end
      end
      return false
    end

    -- Try loading now
    load_dll()

    -- Also try when entering a buffer (covers directory changes)
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        load_dll()
      end,
    })

    vim.api.nvim_create_user_command("DotnetPickDll", function()
      local dll = vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      if dll and dll ~= "" then
        vim.g.dotnet_dap_dll = dll
        vim.fn.writefile({ dll }, get_dll_file())
        vim.notify("Saved DLL: " .. dll, vim.log.levels.INFO)
      end
    end, {})

    vim.api.nvim_create_user_command("DapResetDotnetDll", function()
      vim.g.dotnet_dap_dll = nil
      vim.fn.delete(get_dll_file())
      vim.notify("DAP .NET DLL cleared", vim.log.levels.INFO)
    end, {})

    -- Debug command to check state
    vim.api.nvim_create_user_command("DapDebugDll", function()
      vim.notify("Current DLL: " .. vim.inspect(vim.g.dotnet_dap_dll), vim.log.levels.INFO)
      vim.notify("DLL file: " .. get_dll_file(), vim.log.levels.INFO)
      vim.notify("File exists: " .. tostring(vim.fn.filereadable(get_dll_file()) == 1), vim.log.levels.INFO)
    end, {})
  end,

  config = function()
    local dap = require("dap")

    dap.adapters.coreclr = {
      type = "executable",
      command = "/home/andy/netcoredbg/netcoredbg/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    local launch = {
      type = "coreclr",
      name = "Launch .NET",
      request = "launch",
      program = function()
        vim.notify("program() called, current DLL: " .. vim.inspect(vim.g.dotnet_dap_dll), vim.log.levels.INFO)

        if vim.g.dotnet_dap_dll then
          vim.notify("Returning cached DLL", vim.log.levels.INFO)
          return vim.g.dotnet_dap_dll
        end

        -- Fallback prompt
        vim.notify("No DLL set, prompting...", vim.log.levels.WARN)
        local dll = vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        if dll and dll ~= "" then
          vim.g.dotnet_dap_dll = dll
          vim.fn.writefile({ dll }, vim.fn.getcwd() .. "/.nvim-dap-dll")
        end
        return dll
      end,
      cwd = vim.fn.getcwd(),
      stopAtEntry = false,
      console = "internalConsole",
    }

    dap.configurations.cs = { launch }
    dap.configurations.snacks_picker_list = { launch }
  end,
}
