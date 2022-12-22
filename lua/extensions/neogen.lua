-- https://github.com/danymat/neogen
local M = {}

local extension_name = "neogen"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "danymat/neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufWinEnter",
      }
    end,
    setup = {},
    on_setup = function(config)
      require("neogen").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.LSP] = {
          ["j"] = {
            function()
              require("neogen").generate()
            end,
            "generate documentation",
          },
        },
      }
    end,
  })
end

return M
