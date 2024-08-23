-- https://github.com/mizlan/iswap.nvim
local M = {}

M.name = "mizlan/iswap.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "mizlan/iswap.nvim",
        event = "BufReadPre",
      }
    end,
    setup = function()
      return {
        -- The keys that will be used as a selection, in order
        -- ('asdfghjklqwertyuiopzxcvbnm' by default)
        keys = nvim.selection_chars,
        -- Move cursor to the other element in ISwap*With commands
        -- default false
        move_cursor = true,

        -- Automatically swap with only two arguments
        -- default nil
        autoswap = true,
      }
    end,
    on_setup = function(c)
      require("iswap").setup(c)
    end,
    keymaps = function()
      return {
        {
          "HH",
          ":ISwapNodeWithLeft<CR>",
          desc = "swap with left node",
          mode = { "n" },
        },
        {
          "LL",
          ":ISwapNodeWithRight<CR>",
          desc = "swap with left node",
          mode = { "n" },
        },
        {
          "HL",
          ":ISwapWith<CR>",
          desc = "swap with selected node",
          mode = { "n" },
        },
      }
    end,
  })
end

return M
