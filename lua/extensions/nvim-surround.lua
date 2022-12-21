-- https://github.com/kylechui/nvim-surround

local M = {}

local extension_name = "nvim_surround"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "kylechui/nvim-surround",
        config = function()
          require("utils.setup").plugin_init "nvim_surround"
        end,
        event = "BufWinEnter",
        enabled = config.active,
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
