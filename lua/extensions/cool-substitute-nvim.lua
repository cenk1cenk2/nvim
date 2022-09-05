-- https://github.com/otavioschwanck/cool-substitute.nvim

local M = {}

local setup = require "utils.setup"

local extension_name = "cool_substitute_nvim"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "otavioschwanck/cool-substitute.nvim",
        branch = "main",
        config = function()
          require("utils.setup").packer_config "cool_substitute_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      setup_keybindings = true,
      mappings = {
        start = "gm", -- Mark word / region
        start_and_edit = "gM", -- Mark word / region and also edit
        start_and_edit_word = "g!M", -- Mark word / region and also edit.  Edit only full word.
        start_word = "g!m", -- Mark word / region. Edit only full word
        apply_substitute_and_next = "M", -- Start substitution / Go to next substitution
        apply_substitute_and_prev = "<C-b>", -- same as M but backwards
        apply_substitute_all = "ga", -- Substitute all
      },
      reg_char = "o", -- letter to save macro (Dont use number or uppercase here)
      mark_char = "t", -- mark the position at start of macro
    },
    on_setup = function(config)
      require("cool-substitute").setup(config.setup)
    end,
  })
end

return M
