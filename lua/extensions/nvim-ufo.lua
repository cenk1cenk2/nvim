-- https://github.com/kevinhwang91/nvim-ufo

local setup = require "utils.setup"

local M = {}

local extension_name = "nvim_ufo"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "kevinhwang91/nvim-ufo",
        requires = { "kevinhwang91/promise-async" },
        config = function()
          require("utils.setup").packer_config "nvim_ufo"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        ufo = require "ufo",
      }
    end,
    setup = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    on_setup = function(config)
      require("ufo").setup(config.setup)
    end,
    on_done = function()
      -- vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.foldexpr = "manual"
    end,
    keymaps = function(config)
      local ufo = config.inject.ufo

      return {
        ["zR"] = { { "n", "v", "vb" }, ufo.openAllFolds, { desc = "open all folds - ufo" } },
        ["zM"] = { { "n", "v", "vb" }, ufo.closeAllFolds, { desc = "close all folds - ufo" } },
      }
    end,
  })
end

return M
