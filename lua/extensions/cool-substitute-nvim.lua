local M = {}

local extension_name = "cool_substitute_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      {
        setup_keybindings = true,
        -- mappings = {
        --   start = 'gm', -- Mark word / region
        --   start_and_edit = 'gM', -- Mark word / region and also edit
        --   start_and_edit_word = 'g!M', -- Mark word / region and also edit.  Edit only full word.
        --   start_word = 'g!m', -- Mark word / region. Edit only full word
        --   apply_substitute_and_next = 'M', -- Start substitution / Go to next substitution
        --   apply_substitute_and_prev = '<C-b>', -- same as M but backwards
        --   apply_substitute_all = 'ga', -- Substitute all
        -- },
        -- reg_char = 'o', -- letter to save macro (Dont use number or uppercase here)
        -- mark_char = 't' -- mark the position at start of macro
      },
    },
  }
end

function M.setup()
  local extension = require "cool-substitute"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
