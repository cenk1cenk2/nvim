-- https://github.com/uga-rosa/ccc.nvim
local M = {}

local extension_name = "ccc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "uga-rosa/ccc.nvim",
        config = function()
          require("utils.setup").packer_config "ccc_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("ccc").setup(config.setup)
    end,
    wk = {
      ["a"] = {
        p = { ":CccPick<CR>", "color picker" },
        C = { ":CccHighlighterToggle<CR>", "highlight colors" },
      },
    },
  })
end

return M
