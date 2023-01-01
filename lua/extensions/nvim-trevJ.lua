-- https://github.com/AckslD/nvim-trevJ.lua

local M = {}

local extension_name = "nvim_treevj"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    plugin = function()
      return {
        "AckslD/nvim-trevJ.lua",
      }
    end,
    setup = {},
    on_setup = function(config)
      require("trevj").setup(config.setup)
    end,
    keymaps = function()
      return {
        n = {
          ["gJ"] = {
            function()
              require("trevj").format_at_cursor()
            end,
            { desc = "split lines" },
          },
        },
      }
    end,
  })
end

return M
