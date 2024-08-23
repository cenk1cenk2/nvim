-- https://github.com/danymat/neogen
local M = {}

M.name = "danymat/neogen"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "danymat/neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("neogen").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.LSP, "j" }),
          function()
            require("neogen").generate()
          end,
          desc = "generate documentation",
        },
      }
    end,
  })
end

return M
