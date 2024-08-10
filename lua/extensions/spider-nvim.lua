-- https://github.com/chrisgrieser/nvim-spider
local M = {}

M.name = "chrisgrieser/nvim-spider"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
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
    keymaps = function()
      return {
        {
          "w",
          function()
            require("spider").motion("w")
          end,
          desc = "spider-w",
          mode = { "n", "o", "x" },
        },
        {
          "W",
          "w",
          desc = "non-spider-w",
          mode = { "n", "o", "x" },
        },
        {
          "gW",
          "W",
          desc = "non-spider-W",
          mode = { "n", "o", "x" },
        },
        {
          "e",
          function()
            require("spider").motion("e")
          end,
          desc = "spider-e",
          mode = { "n", "o", "x" },
        },
        {
          "E",
          "e",
          desc = "non-spider-e",
          mode = { "n", "o", "x" },
        },
        {
          "gE",
          "E",
          desc = "non-spider-E",
          mode = { "n", "o", "x" },
        },
        {
          "b",
          function()
            require("spider").motion("b")
          end,
          desc = "spider-b",
          mode = { "n", "o", "x" },
        },
        {
          "B",
          "b",
          desc = "non-spider-b",
          mode = { "n", "o", "x" },
        },
        {
          "gB",
          "B",
          desc = "non-spider-B",
          mode = { "n", "o", "x" },
        },
      }
    end,
  })
end

return M
