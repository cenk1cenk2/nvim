-- https://github.com/kylechui/nvim-surround

local M = {}

M.name = "kylechui/nvim-surround"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "kylechui/nvim-surround",
        event = "BufReadPost",
      }
    end,
    setup = function()
      return {
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
          ["t"] = ">",
          ["p"] = ")",
          ["c"] = "}",
          ["a"] = "]",
          ["q"] = { '"', "'", "`" },
          ["b"] = { "}", "]", ")" },
          ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
      }
    end,
    on_setup = function(c)
      require("nvim-surround").setup(c)
    end,
  })
end

return M
