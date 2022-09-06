-- https://github.com/gbprod/substitute.nvim
local M = {}

local extension_name = "substitute_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "gbprod/substitute.nvim",
        config = function()
          require("utils.setup").packer_config "substitute_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        substitute = require "substitute",
      }
    end,
    setup = {
      on_substitute = nil,
      yank_substitued_text = false,
      range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        motion1 = false,
        motion2 = false,
      },
      exchange = {
        motion = false,
      },
    },
    on_setup = function(config)
      require("substitute").setup(config.setup)
    end,
    keymaps = function(config)
      local substitute = config.inject.substitute

      return {
        n = {
          ["sd"] = { substitute.operator, { desc = "substitute operator" } },
          ["sds"] = { substitute.line, { desc = "substitute line" } },
          ["sdd"] = { substitute.eol, { desc = "substitute eol" } },
        },
        v = {
          ["sd"] = { substitute.visual, { desc = "substitute visual" } },
        },
      }
    end,
  })
end

return M
