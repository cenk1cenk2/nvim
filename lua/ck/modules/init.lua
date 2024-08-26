local M = {}

local modules = {
  "nvim",
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
      log:error("Module does not exists: %s", path)
    else
      local ok, err = pcall(m.setup)

      if not ok then
        log:error("Module can not be loaded: %s -> %s", path, err)
      end
    end
  end
end

return M
