-- https://github.com/chrisgrieser/nvim-spider
local M = {}

local extension_name = "spider_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "chrisgrieser/nvim-spider",
      }
    end,
    setup = function()
      return {
        skipInsignificantPunctuation = true,
      }
    end,
    on_setup = function(config)
      require("spider").setup(config.setup)
    end,
    keymaps = {
      {
        { "n", "o", "x" },

        ["w"] = {
          function()
            require("spider").motion("w")
          end,
          {
            desc = "spider-w",
          },
        },
        ["e"] = {
          function()
            require("spider").motion("e")
          end,
          {
            desc = "spider-e",
          },
        },
        ["b"] = {
          function()
            require("spider").motion("b")
          end,
          {
            desc = "spider-b",
          },
        },
        -- ["ge"] = {
        --   function()
        --     require("spider").motion("ge")
        --   end,
        --   {
        --     desc = "spider-ge",
        --   },
        -- },
      },
    },
  })
end

return M
