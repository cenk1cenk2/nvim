-- https://github.com/gbprod/yanky.nvim
local M = {}

local extension_name = "yanky_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "gbprod/yanky.nvim",
        config = function()
          require("utils.setup").packer_config "yanky_nvim"
        end,
        disable = not config.active,
      }
    end,
    register = "+",
    to_inject = function()
      return {
        mapping = require "yanky.telescope.mapping",
        default_register = require("yanky.utils").get_default_register(),
        telescope = require "telescope",
      }
    end,
    setup = function(config)
      local mapping = config.inject.mapping
      local register = config.register

      return {
        ring = {
          history_length = 10,
          storage = "shada",
          sync_with_numbered_registers = true,
        },
        system_clipboard = {
          sync_with_ring = true,
        },
        highlight = {
          on_put = true,
          on_yank = true,
          timer = 500,
        },
        preserve_cursor_position = {
          enabled = true,
        },
        picker = {
          telescope = {
            mappings = {
              default = mapping.set_register(register),
              i = {
                ["<c-p>"] = mapping.put "p",
                ["<c-P>"] = mapping.put "P",
                ["<c-d>"] = mapping.delete(),
                ["<c-r>"] = mapping.set_register(register),
              },
              n = {
                ["p"] = mapping.put "p",
                ["P"] = mapping.put "P",
                ["d"] = mapping.delete(),
                ["r"] = mapping.set_register(register),
              },
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("yanky").setup(config.setup)
    end,
    on_done = function(config)
      config.inject.telescope.load_extension "yank_history"
    end,
    keymaps = function()
      local defaults = {
        ["gq"] = { "<Plug>(YankyCycleForward)", desc = "yank cycle forward" },
        ["gQ"] = { "<Plug>(YankyCycleBackward)", desc = "yank cycle backward" },
        ["y"] = { "<Plug>(YankyYank)", desc = "yanky put before" },
        -- ["gp"] = { "<Plug>(YankyPutAfterFilter)", desc = "yanky put after filter" },
        -- ["gP"] = { "<Plug>(YankyPutBeforeFilter)", desc = "yanky put before filter" },
        -- vim.api.nvim_set_keymap("n", "p", "<Plug>(YankyPutAfter)", {})
        -- vim.api.nvim_set_keymap("n", "P", "<Plug>(YankyPutBefore)", {})
        -- vim.api.nvim_set_keymap("x", "p", "<Plug>(YankyPutAfter)", {})
        -- vim.api.nvim_set_keymap("x", "P", "<Plug>(YankyPutBefore)", {})
        -- vim.api.nvim_set_keymap("n", "gp", "<Plug>(YankyGPutAfter)", {})
        -- vim.api.nvim_set_keymap("n", "gP", "<Plug>(YankyGPutBefore)", {})
        -- vim.api.nvim_set_keymap("x", "gp", "<Plug>(YankyGPutAfter)", {})
        -- vim.api.nvim_set_keymap("x", "gP", "<Plug>(YankyGPutBefore)", {})
      }

      local visual = {
        ["p"] = { "<Plug>(YankyPutAfter)", desc = "yanky put after" },
        ["P"] = { "<Plug>(YankyPutBefore)", desc = "yanky put before" },
      }

      return {
        n = defaults,
        v = vim.tbl_extend("force", vim.deepcopy(defaults), visual),
        vb = vim.tbl_extend("force", vim.deepcopy(defaults), visual),
      }
    end,
    wk = {
      ["y"] = { ":Telescope yank_history<CR>", "list yanky.nvim registers" },
    },
  })
end

return M
