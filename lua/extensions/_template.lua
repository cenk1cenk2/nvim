--
local M = {}

local extension_name = "template"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "template",
        enabled = config.active,
      }
    end,
  })
end

return M
