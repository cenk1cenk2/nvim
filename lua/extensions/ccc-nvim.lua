-- https://github.com/uga-rosa/ccc.nvim
local M = {}

local extension_name = "ccc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccHighlighterToggle" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("ccc").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          c = { ":CccHighlighterToggle<CR>", "highlight colors" },
          C = { ":CccPick<CR>", "color picker" },
        },
      }
    end,
  })
end

return M
