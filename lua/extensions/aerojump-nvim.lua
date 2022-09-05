local M = {}

local setup = require "utils.setup"

local extension_name = "aerojump_nvim"

function M.config()
  setup.define_extension(extension_name, true, {
    on_config_done = nil,
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

function M.setup()
  local config = setup.get_config(extension_name)

  setup.legacy_setup(config.legacy_setup)

  setup.load_wk_mappings(config.wk)

  setup.on_setup_done(config)
end

return M
