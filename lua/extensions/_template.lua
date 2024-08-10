--
local M = {}

M.name = "template"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "template",
      }
    end,
  })
end

return M
