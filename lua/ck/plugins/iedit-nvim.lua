-- https://github.com/altermo/iedit.nvim
local M = {}

M.name = "altermo/iedit.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "altermo/iedit.nvim",
      }
    end,
    setup = function()
      return {
        highlight = "CurSearch",
      }
    end,
    on_setup = function(c)
      require("iedit").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.SEARCH, "i" }),
          group = "iedit",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "r" }),
          function()
            require("iedit").restrict_visual()
          end,
          desc = "start iedit",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "i" }),
          function()
            require("iedit").toggle()
          end,
          desc = "start iedit",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "n" }),
          function()
            require("iedit").goto_next_occurrence(true)
          end,
          desc = "[iedit] go to next occurrence",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "N" }),
          function()
            require("iedit").goto_first_occurrence()
          end,
          desc = "[iedit] go to first occurrence",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "p" }),
          function()
            require("iedit").goto_prev_occurrence(true)
          end,
          desc = "[iedit] go to previous occurrence",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "P" }),
          function()
            require("iedit").goto_last_occurrence()
          end,
          desc = "[iedit] go to last occurrence",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "i", "t" }),
          function()
            require("iedit").toggle_current_occurrence()
          end,
          desc = "[iedit] toggle current occurrence",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

return M
