--
local M = {}

M.name = "template"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "template",
      }
    end,
  })
end

return M
