-- https://github.com/kylechui/nvim-surround

local setup = require "utils.setup"

local M = {}

local extension_name = "nvim_surround"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "kylechui/nvim-surround",
        config = function()
          require("utils.setup").packer_config "nvim_surround"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
      },
      aliases = {
        ["a"] = ">",
        ["w"] = ")",
        ["e"] = "}",
        ["r"] = "]",
        ["q"] = { '"', "'", "`" },
        ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
      },
    },
    on_setup = function(config)
      require("nvim-surround").setup(config.setup)
    end,
  })
end

return M
