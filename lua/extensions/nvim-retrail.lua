-- https://github.com/zakharykaplan/nvim-retrail
local M = {}

local extension_name = "nvim_retrail"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "zakharykaplan/nvim-retrail",
        event = "VeryLazy",
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
          exclude = vim.list_extend({ "" }, lvim.disabled_filetypes),
        },
        -- Trim on write behaviour.
        trim = {
          -- Trailing whitespace as highlighted.
          whitespace = true,
          -- Final blank (i.e. whitespace only) lines.
          blanklines = false,
        },
      }
    end,
    on_setup = function(config)
      require("retrail").setup(config.setup)
    end,
  })
end

return M
