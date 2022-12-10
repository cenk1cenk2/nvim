-- https://github.com/nvim-zh/colorful-winsep.nvim
local M = {}

local extension_name = "colorful_winsep_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "nvim-zh/colorful-winsep.nvim",
        config = function()
          require("utils.setup").packer_config "colorful_winsep_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      -- highlight for Window separator
      highlight = {
        -- guibg = "#16161E",
        guifg = require("onedarker.colors").bg[400],
      },
      -- timer refresh rate
      interval = 30,
      -- This plugin will not be activated for filetype in the following table.
      no_exec_files = lvim.disabled_filetypes,
      -- Symbols for separator lines, the order: horizontal, vertical, top left, top right, bottom left, bottom right.
      symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
      close_event = function()
        -- Executed after closing the window separator
      end,
      create_event = function()
        -- Executed after creating the window separator
      end,
    },
    on_setup = function(config)
      require("colorful-winsep").setup(config.setup)
    end,
  })
end

return M
