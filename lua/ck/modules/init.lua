local M = {}

local modules = {
  "nvim",
  "logs",
  "commands",
  "autocmds",
  "filetype",
  "executables",
  "quit",
  -- rest
  "unimpaired",
  "scratch",
}

function M.config()
  local log = require("ck.log")

  for _, path in ipairs(modules) do
    local ok, m = pcall(require, ("ck.modules.%s"):format(path))
    if not ok then
      log:warn("Module can not be loaded: %s", path)
    elseif m.setup ~= nil then
      m.setup()
    end
  end
end

return M
