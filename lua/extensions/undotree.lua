--
local M = {}

local extension_name = "undotree"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "mbbill/undotree",
        cmd = { "UndotreeToggle" },
      }
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["u"] = { ":UndotreeToggle<CR>", "toggle undo tree" },
        },
      }
    end,
  })
end

return M
