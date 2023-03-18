-- https://github.com/Wansmer/treesj
local M = {}

local extension_name = "treesj"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter" },
      }
    end,
    setup = function()
      return {
        -- Use default keymaps
        -- (<space>m - toggle, <space>j - join, <space>s - split)
        use_default_keymaps = false,

        -- Node with syntax error will not be formatted
        check_syntax_error = true,

        -- If line after join will be longer than max value,
        -- node will not be formatted
        max_join_length = 180,

        -- hold|start|end:
        -- hold - cursor follows the node/place on which it was called
        -- start - cursor jumps to the first symbol of the node being formatted
        -- end - cursor jumps to the last symbol of the node being formatted
        cursor_behavior = "hold",

        -- Notify about possible problems or not
        notify = true,
        -- langs = langs,

        dot_repeat = false,
      }
    end,
    on_setup = function(config)
      require("treesj").setup(config.setup)
    end,
    keymaps = function()
      return {
        n = {
          ["gJ"] = {
            function()
              require("treesj").toggle()
            end,
            { desc = "split lines" },
          },
        },
      }
    end,
  })
end

return M
