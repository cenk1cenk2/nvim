-- https://github.com/zakharykaplan/nvim-retrail
local M = {}

M.name = "zakharykaplan/nvim-retrail"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "zakharykaplan/nvim-retrail",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        -- Highlight group to use for trailing whitespace.
        hlgroup = "ExtraWhitespace",
        -- Pattern to match trailing whitespace against. Edit with caution!
        pattern = "\\v((.*%#)@!|%#)\\s+$",
        -- Enabled filetypes.
        filetype = {
          -- Strictly enable only on `include`ed filetypes. When false, only disabled
          -- on an `exclude`ed filetype.
          strict = false,
          -- Included filetype list.
          include = {},
          -- Excluded filetype list. Overrides `include` list.
          exclude = vim.list_extend({ "" }, nvim.disabled_filetypes),
        },
        -- Trim on write behaviour.
        trim = {
          auto = false,
          -- Trailing whitespace as highlighted.
          whitespace = false,
          -- Final blank (i.e. whitespace only) lines.
          blanklines = false,
        },
      }
    end,
    on_setup = function(c)
      require("retrail").setup(c)
    end,
  })
end

return M
