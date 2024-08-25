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
  "lsp-setup",
  "unimpaired",
  "scratch",
}

function M.config()
  local log = require("ck.log")

  for _, path in ipairs(modules) do
    local ok, m = pcall(require, "ck.modules." .. path)
    if not ok then
      log:warn("Module can not be loaded: %s", path)
    elseif m.setup ~= nil then
      m.setup()
    end
  end
end

return M
