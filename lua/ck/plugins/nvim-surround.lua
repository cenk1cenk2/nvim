-- https://github.com/kylechui/nvim-surround

local M = {}

M.name = "kylechui/nvim-surround"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "kylechui/nvim-surround",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      ---@type user_options
      return {
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "s",
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
