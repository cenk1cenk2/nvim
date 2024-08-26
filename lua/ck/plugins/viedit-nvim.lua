-- https://github.com/viocost/viedit
local M = {}

M.name = "viocost/viedit"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "viocost/viedit",
      }
    end,
    setup = function()
      return {
        -- Highlight group for marked text
        -- Can use any highlight group definitions
        highlight = "IncSearch",

        -- Highlight group for the marked text where cursor currently is
        current_highlight = {
          link = "CurSearch",
        },

        -- Determines the behavior of the end of the mark when text is inserted
        -- true: the end of the mark stays at its position (moves with inserted text)
        -- false: the end of the mark moves as text is inserted
        end_right_gravity = true,

        -- Determines the behavior of the start of the mark when text is inserted
        -- true: the start of the mark stays at its position (moves with inserted text)
        -- false: the start of the mark remains fixed as text is inserted
        right_gravity = false,

        -- It may be useful to keep semantics of next/previous keys
        -- If this is true, default mappings for specified keys will be overriden
        -- to do viedit operations while viedit mode is enabled
        -- true: override specified keys while in viedit mode
        -- false: do not override any keys
        override_keys = true,

        -- Defines keys that will be overriden and mapped to viedit operations
        -- If override_keys is off - this won't be applied
        keys = {
          -- Key to move to the next occurrence of the marked text
          next_occurrence = "n",
          -- Key to move to the previous occurrence of the marked text
          previous_occurrence = "N",
          -- Toggle individual occurrence to/from selection
          toggle_single = ";",
        },
      }
    end,
    on_setup = function(c)
      require("viedit").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "i" }),
          function()
            require("viedit").toggle_single()
          end,
          desc = "start iedit",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TASKS, "I" }),
          function()
            require("viedit").toggle_all()
          end,
          desc = "start iedit select all",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

return M
