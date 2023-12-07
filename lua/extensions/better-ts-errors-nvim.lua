-- https://github.com/OlegGulevskyy/better-ts-errors.nvim
local M = {}

local extension_name = "OlegGulevskyy/better-ts-errors.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "OlegGulevskyy/better-ts-errors.nvim",
        ft = { "typescript", "typescriptreact" },
      }
    end,
    setup = function()
      return {
        keymaps = {
          toggle = "<leader>le",
          go_to_definition = "<leader>lE",
        },
      }
    end,
    on_setup = function(config)
      require("better-ts-errors").setup(config.setup)
    end,
  })
end

return M
