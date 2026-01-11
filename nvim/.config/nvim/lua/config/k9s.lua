-- lua/config/k9s.lua

local ok, term = pcall(require, "toggleterm.terminal")
if not ok then
  return {}
end

local k9s = term.Terminal:new({
  cmd = "k9s",
  hidden = true,
  direction = "float",
  float_opts = { border = "rounded" },
  on_open = function()
    vim.cmd("startinsert!")
  end,

  on_close = function()
    vim.cmd("stopinsert!")
  end,
})

local M = {}

function M.toggle()
  k9s:toggle()
end

return M
