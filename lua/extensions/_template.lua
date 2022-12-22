--
local M = {}

local extension_name = "template"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "template",
      }
    end,
  })
end

return M
