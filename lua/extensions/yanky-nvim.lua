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
          "gq",
          "<Plug>(YankyPreviousEntry)",
          desc = "yank cycle forward",
          mode = { "n", "v", "x" },
        },
        {
          "gQ",
          "<Plug>(YankyNextEntry)",
          desc = "yank cycle backward",
          mode = { "n", "v", "x" },
        },
        {
          "y",
          "<Plug>(YankyYank)",
          desc = "yanky",
          mode = { "n", "v", "x" },
        },
        {
          "p",
          "<Plug>(YankyPutAfter)",
          desc = "yanky put after",
          mode = { "n" },
        },
        {
          "P",
          "<Plug>(YankyPutBefore)",
          desc = "yanky put before",
          mode = { "n" },
        },
        {
          "P",
          "<Plug>(YankyPutAfter)",
          desc = "yanky put after",
          mode = { "v", "x" },
        },
        {
          "p",
          "<Plug>(YankyPutBefore)",
          desc = "yanky put before",
          mode = { "v", "x" },
        },
        {
          "gp",
          "<Plug>(YankyPutAfterCharwise)",
          desc = "unconditional paste",
          mode = { "n", "v", "x" },
        },
        {
          "gP",
          "<Plug>(YankyPutBeforeCharwise)",
          desc = "unconditional paste before",
          mode = { "n", "v", "x" },
        },
      }
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "y" }),
          function()
            require("telescope").extensions.yank_history.yank_history()
          end,
          desc = "list yanky.nvim registers",
        },
      }
    end,
  })
end

return M
