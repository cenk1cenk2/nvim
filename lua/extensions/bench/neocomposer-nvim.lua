-- https://github.com/ecthelionvi/NeoComposer.nvim
local M = {}

local extension_name = "neocomposer_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    plugin = function()
      return {
        "ecthelionvi/NeoComposer.nvim",
        keys = { "Q", "@", "#", "<M-#>", "<M-q>", "<M-Q>", "cq", "yq", "cqq" },
        dependencies = { "kkharji/sqlite.lua" },
      }
    end,
    setup = function()
      return {
        notify = true,
        delay_timer = "150",
        status_bg = lvim.ui.colors.bg[100],
        preview_fg = lvim.ui.colors.orange[600],
        keymaps = {
          play_macro = "@",
          yank_macro = "yq",
          stop_macro = "cq",
          toggle_record = "Q",
          cycle_next = "#",
          cycle_prev = "<M-#>",
          toggle_macro_menu = "<M-q>",
        },
      }
    end,
    on_setup = function(config)
      require("NeoComposer").setup(config.setup)
    end,
    on_done = function()
      require("telescope").load_extension("macros")
    end,
    keymaps = {
      {
        { "n" },

        ["q"] = "<Nop>",
        ["<M-Q>"] = {
          function()
            require("telescope").extensions.macros.macros({})
          end,
          { desc = "macros" },
        },
      },
    },
  })
end

return M
