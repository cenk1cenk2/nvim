-- https://github.com/Wansmer/treesj
local M = {}

M.name = "Wansmer/treesj"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter" },
      }
    end,
    setup = function()
      local utils = require("treesj.langs.utils")

      local langs = {
        terraform = utils.merge_preset(require("treesj.langs.javascript"), {}),
      }

      return {
        -- Use default keymaps
        -- (<space>m - toggle, <space>j - join, <space>s - split)
        use_default_keymaps = false,

        -- Node with syntax error will not be formatted
        check_syntax_error = true,

        -- If line after join will be longer than max value,
        -- node will not be formatted
        max_join_length = math.huge,

        -- hold|start|end:
        -- hold - cursor follows the node/place on which it was called
        -- start - cursor jumps to the first symbol of the node being formatted
        -- end - cursor jumps to the last symbol of the node being formatted
        cursor_behavior = "hold",

        -- Notify about possible problems or not
        notify = true,

        dot_repeat = false,

        langs = langs,
      }
    end,
    on_setup = function(c)
      require("treesj").setup(c)
    end,
    keymaps = function()
      return {
        {
          "gJ",
          function()
            require("treesj").toggle()
          end,
          desc = "split lines",
          mode = { "n" },
        },
      }
    end,
  })
end

return M
