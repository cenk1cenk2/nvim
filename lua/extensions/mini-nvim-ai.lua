-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
local M = {}

local extension_name = "mini_nvim_ai"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "echasnovski/mini.ai",
        enabled = config.active,
      }
    end,
    setup = {
      -- Table with textobject id as fields, textobject specification as values.
      -- Also use this to disable builtin textobjects. See |MiniAi.config|.
      custom_textobjects = nil,

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Main textobject prefixes
        around = "a",
        inside = "i",

        -- Next/last variants
        around_next = "an",
        inside_next = "in",
        around_last = "al",
        inside_last = "il",

        -- Move cursor to corresponding edge of `a` textobject
        goto_left = "g[",
        goto_right = "g]",
      },

      -- Number of lines within which textobject is searched
      n_lines = 1,

      -- How to search for object (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
      search_method = "cover",
    },
    on_setup = function(config)
      require("mini.ai").setup(config.setup)
    end,
  })
end

return M
