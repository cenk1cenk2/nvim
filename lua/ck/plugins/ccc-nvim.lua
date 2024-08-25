-- https://github.com/uga-rosa/ccc.nvim
local M = {}

M.name = "uga-rosa/ccc.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccHighlighterToggle" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("ccc").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "c" }),
          function()
            vim.cmd([[CccPick]])
          end,
          desc = "color picker",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "C" }),
          function()
            vim.cmd([[CccHighlighterToggle]])
          end,
          desc = "highlight colors",
        },
      }
    end,
  })
end

return M