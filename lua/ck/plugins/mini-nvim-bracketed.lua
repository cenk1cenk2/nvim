-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
local M = {}

M.name = "echasnovski/mini.bracketed"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "echasnovski/mini.bracketed",
        event = "BufReadPost",
      }
    end,
    setup = function()
      return {
        buffer = { suffix = "b", options = {} },
        comment = { suffix = "c", options = {} },
        conflict = { suffix = "n", options = {} },
        diagnostic = { suffix = "d", options = {} },
        file = { suffix = "f", options = {} },
        indent = { suffix = "i", options = {} },
        jump = { suffix = "j", options = {} },
        location = { suffix = "l", options = {} },
        oldfile = { suffix = "o", options = {} },
        quickfix = { suffix = "q", options = {} },
        treesitter = { suffix = "t", options = {} },
        undo = { suffix = "u", options = {} },
        window = { suffix = "w", options = {} },
        yank = { suffix = "y", options = {} },
      }
    end,
    on_setup = function(c)
      require("mini.bracketed").setup(c)
    end,
  })
end

return M
