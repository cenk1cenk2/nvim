-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
local M = {}

local extension_name = "mini_nvim_bracketed"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
    on_setup = function(config)
      require("mini.bracketed").setup(config.setup)
    end,
  })
end

return M
