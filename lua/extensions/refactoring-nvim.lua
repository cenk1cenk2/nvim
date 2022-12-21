-- https://github.com/ThePrimeagen/refactoring.nvim
local M = {}

local extension_name = "refactoring_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
          { "nvim-treesitter/nvim-treesitter" },
        },
        config = function()
          require("utils.setup").plugin_init "refactoring_nvim"
        end,
        enabled = config.active,
      }
    end,
    to_inject = function()
      return {
        refactoring = require "refactoring",
      }
    end,
    setup = {},
    on_setup = function(config)
      require("refactoring").setup(config.setup)
    end,
    keymaps = function(config)
      local refactoring = config.inject.refactoring

      return {
        v = {
          ["re"] = {
            function()
              refactoring.refactor "Extract Function"
            end,
            { desc = "extract to function" },
          },
          ["rf"] = {
            function()
              refactoring.refactor "Extract Function To File"
            end,
            { desc = "extract function to file" },
          },
          ["rv"] = {
            function()
              refactoring.refactor "Extract Variable"
            end,
            { desc = "extract variable" },
          },
          ["ri"] = {
            function()
              refactoring.refactor "Inline Variable"
            end,
            { desc = "extract inline variable" },
          },
        },
      }
    end,
  })
end

return M
