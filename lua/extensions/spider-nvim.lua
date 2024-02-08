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
        ["W"] = {
          "w",
          {
            desc = "non-spider-w",
          },
        },
        ["gW"] = {
          "W",
          {
            desc = "non-spider-W",
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
        ["E"] = {
          "e",
          {
            desc = "non-spider-e",
          },
        },
        ["gE"] = {
          "E",
          {
            desc = "non-spider-E",
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
        ["B"] = {
          "b",
          {
            desc = "non-spider-b",
          },
        },
        ["gB"] = {
          "B",
          {
            desc = "non-spider-B",
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
