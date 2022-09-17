--
local M = {}

local extension_name = "template"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "template",
        config = function()
          require("utils.setup").packer_config "template"
        end,
        disable = not config.active,
      }
    end,
  })
end

return M
