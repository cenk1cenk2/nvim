--
local M = {}

local extension_name = "undotree"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "mbbill/undotree",
        config = function()
          require("utils.setup").packer_config "undotree"
        end,
        disable = not config.active,
      }
    end,
    wk = { ["u"] = { ":UndotreeToggle<CR>", "toggle undo tree" } },
  })
end

return M
