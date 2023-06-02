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
    setup = function()
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
    keymaps = {
      {
        { "n" },

        ["sd"] = {
          function()
            require("substitute").operator()
          end,
          { desc = "substitute operator" },
        },
        ["sds"] = {
          function()
            require("substitute").line()
          end,
          { desc = "substitute line" },
        },
        ["sdd"] = {
          function()
            require("substitute").eol()
          end,
          { desc = "substitute eol" },
        },
      },

      {
        { "v" },

        ["sd"] = {
          function()
            require("substitute").visual()
          end,
          { desc = "substitute visual" },
        },
      },
    },
  })
end

return M
