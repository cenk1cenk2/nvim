-- https://github.com/ThePrimeagen/refactoring.nvim
local M = {}

local extension_name = "refactoring_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
          { "nvim-treesitter/nvim-treesitter" },
        },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("refactoring").setup(config.setup)
    end,
    keymaps = {
      {
        { "v" },

        ["re"] = {
          function()
            require("refactoring").refactor("Extract Function")
          end,
          { desc = "extract to function" },
        },
        ["rf"] = {
          function()
            require("refactoring").refactor("Extract Function To File")
          end,
          { desc = "extract function to file" },
        },
        ["rv"] = {
          function()
            require("refactoring").refactor("Extract Variable")
          end,
          { desc = "extract variable" },
        },
        ["ri"] = {
          function()
            require("refactoring").refactor("Inline Variable")
          end,
          { desc = "extract inline variable" },
        },
      },
    },
  })
end

return M
