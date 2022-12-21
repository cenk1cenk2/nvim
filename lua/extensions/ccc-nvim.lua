-- https://github.com/uga-rosa/ccc.nvim
local M = {}

local extension_name = "ccc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "uga-rosa/ccc.nvim",
        config = function()
          require("utils.setup").plugin_init "ccc_nvim"
        end,
        cmd = { "CccPick", "CccHighlighterToggle" },
        enabled = config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("ccc").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          p = { ":CccPick<CR>", "color picker" },
          C = { ":CccHighlighterToggle<CR>", "highlight colors" },
        },
      }
    end,
  })
end

return M
