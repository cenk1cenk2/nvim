-- https://github.com/zakharykaplan/nvim-retrail

local setup = require "utils.setup"

local M = {}

local extension_name = "nvim_retrail"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "zakharykaplan/nvim-retrail",
        config = function()
          require("utils.setup").packer_config "nvim_retrail"
        end,
        disable = not config.active,
      }
    end,
    setup = {
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
        exclude = {
          "far",
          "diff",
          "gitcommit",
          "help",
          "dashboard",
          "alpha",
          "spectre_panel",
          "LspTrouble",
          "TelescopePrompt",
          "floaterm",
          "toggleterm",
          "mason.nvim",
        },
      },
      -- Trim on write behaviour.
      trim = {
        -- Trailing whitespace as highlighted.
        whitespace = true,
        -- Final blank (i.e. whitespace only) lines.
        blanklines = false,
      },
    },
    on_setup = function(config)
      require("retrail").setup(config.setup)
    end,
  })
end

return M
