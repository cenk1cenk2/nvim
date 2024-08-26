-- https://github.com/gbprod/substitute.nvim
local M = {}

M.name = "gbprod/substitute.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "gbprod/substitute.nvim",
      }
    end,
    setup = function()
      return {
        on_substitute = require("yanky.integration").substitute(),
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
    on_setup = function(c)
      require("substitute").setup(c)
    end,
    keymaps = function()
      return {
        {
          "sd",
          function()
            require("substitute").operator()
          end,
          desc = "substitute operator",
          mode = { "n" },
        },
        {
          "sds",
          function()
            require("substitute").line()
          end,
          desc = "substitute line",
          mode = { "n" },
        },
        {
          "sdd",
          function()
            require("substitute").eol()
          end,
          desc = "substitute eol",
          mode = { "n" },
        },
        {
          "sd",
          function()
            require("substitute").visual()
          end,
          desc = "substitute visual",
          mode = { "v" },
        },
      }
    end,
  })
end

return M
