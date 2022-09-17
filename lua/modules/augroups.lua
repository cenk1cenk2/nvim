local M = {}

function M.setup()
  require("utils.setup").run {
    autocmds = {},
  }
end

return M
