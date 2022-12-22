-- https://github.com/gbprod/substitute.nvim
local M = {}

local extension_name = "substitute_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "gbprod/substitute.nvim",
      }
    end,
    to_inject = function()
      -- local _, yanky = pcall(require, "yanky")

      return {
        substitute = require("substitute"),
        -- yanky = yanky,
      }
    end,
    setup = function(config)
      return {
        -- on_substitute = function(event)
        --   if config.inject.yanky ~= nil then
        --     config.inject.yanky.init_ring("p", event.register, event.count, event.vmode:match "[vV�]")
        --   end
        -- end,
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
      }
    end,
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
