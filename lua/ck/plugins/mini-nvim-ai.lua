-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md
local M = {}

M.name = "echasnovski/mini.ai"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "echasnovski/mini.ai",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        -- Table with textobject id as fields, textobject specification as values.
        -- Also use this to disable builtin textobjects. See |MiniAi.config|.
        custom_textobjects = nil,

        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          -- Main textobject prefixes
          around = "a",
          inside = "i",

          -- Move cursor to corresponding edge of `a` textobject
          goto_left = "g[",
          goto_right = "g]",
        },

        -- Number of lines within which textobject is searched
        n_lines = 50,

        -- How to search for object (first inside current line, then inside
        -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
        -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
        search_method = "cover",
      }
    end,
    on_setup = function(c)
      require("mini.ai").setup(c)
    end,
  })
end

return M
