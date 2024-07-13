-- https://github.com/uga-rosa/ccc.nvim
local M = {}

local extension_name = "ccc_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccHighlighterToggle" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("ccc").setup(config.setup)
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
