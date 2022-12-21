--
local M = {}

local extension_name = "template"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "template",
        config = function()
          require("utils.setup").plugin_init "template"
        end,
        enabled = config.active,
      }
    end,
  })
end

return M
