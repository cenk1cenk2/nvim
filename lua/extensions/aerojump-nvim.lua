-- https://github.com/ripxorip/aerojump.nvim
local M = {}

local extension_name = "aerojump_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "ripxorip/aerojump.nvim",
        config = function()
          require("utils.setup").packer_config "aerojump_nvim"
        end,
        disable = not config.active,
        run = ":UpdateRemotePlugins",
      }
    end,
    on_done = function()
      lvim.extensions.cmp.per_ft.AerojumpFilter = { sources = {} }
    end,
    legacy_setup = {
      aerojump_bolt_lines_before = 3,
      aerojump_bolt_lines_after = 3,
      aerojump_keymaps = {
        ["<C-p>"] = "AerojumpUp",
        ["<Left>"] = "AerojumpSelPrev",
        ["<C-g>"] = "AerojumpSelPrev",
        ["<C-j>"] = "AerojumpSelect",
        ["<Down>"] = "AerojumpDown",
        ["<C-k>"] = "AerojumpUp",
        ["<Up>"] = "AerojumpUp",
        ["<C-n>"] = "AerojumpDown",
        ["<Right>"] = "AerojumpSelNext",
        ["<C-l>"] = "AerojumpSelNext",
        ["<C-q>"] = "AerojumpExit",
        ["<ESC>"] = "AerojumpSelect",
        ["<CR>"] = "AerojumpSelect",
      },
    },
    wk = {
      ["f"] = {
        ["a"] = {
          ":Aerojump kbd bolt<CR>",
          "aerojump",
        },
      },
    },
  })
end

return M
