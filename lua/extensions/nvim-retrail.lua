local M = {}

local extension_name = "nvim_retrail"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
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
  }
end

function M.setup()
  local extension = require "retrail"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
