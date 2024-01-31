-- https://github.com/gbprod/yanky.nvim
local M = {}

local extension_name = "yanky_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "gbprod/yanky.nvim",
        -- cmd = { "Telescope yanky" },
        event = "BufReadPost",
      }
    end,
    setup = function()
      local mapping = require("yanky.telescope.mapping")
      local system_register = lvim.system_register
      -- local default_register = require("yanky.utils").get_default_register()

      return {
        ring = {
          history_length = 10,
          storage = "shada",
          sync_with_numbered_registers = true,
          cancel_event = "update",
          ignore_registers = { "_" },
          update_register_on_cycle = true,
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
        textobj = {
          enabled = false,
        },
        picker = {
          telescope = {
            mappings = {
              default = mapping.set_register(system_register),
              i = {
                ["<c-p>"] = mapping.put("p"),
                ["<c-P>"] = mapping.put("P"),
                ["<c-d>"] = mapping.delete(),
                ["<c-r>"] = mapping.set_register(system_register),
              },
              n = {
                ["p"] = mapping.put("p"),
                ["P"] = mapping.put("P"),
                ["d"] = mapping.delete(),
                ["r"] = mapping.set_register(system_register),
              },
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("yanky").setup(config.setup)
    end,
    on_done = function()
      require("telescope").load_extension("yank_history")
    end,
    keymaps = function()
      return {
        {
          { "n", "v", "vb", "t" },
          ["gq"] = {
            "<Plug>(YankyPreviousEntry)",
            desc = "yank cycle forward",
          },
          ["gQ"] = {
            "<Plug>(YankyNextEntry)",
            desc = "yank cycle backward",
          },
          ["y"] = {
            "<Plug>(YankyYank)",
            desc = "yanky",
          },
        },

        {
          { "n", "t" },
          ["p"] = {
            "<Plug>(YankyPutAfter)",
            desc = "yanky put after",
          },
          ["P"] = {
            "<Plug>(YankyPutBefore)",
            desc = "yanky put before",
          },
        },

        {
          { "v", "vb" },
          ["P"] = {
            "<Plug>(YankyPutAfter)",
            desc = "yanky put after",
          },
          ["p"] = {
            "<Plug>(YankyPutBefore)",
            desc = "yanky put before",
          },
        },

        {
          { "n", "v", "vb", "t" },

          ["gp"] = {
            "<Plug>(YankyPutAfterCharwise)",
            "unconditional paste",
          },
          ["gP"] = {
            "<Plug>(YankyPutBeforeCharwise)",
            "unconditional paste before",
          },
        },
      }
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["y"] = { ":Telescope yank_history<CR>", "list yanky.nvim registers" },
        },
      }
    end,
  })
end

return M
