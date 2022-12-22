-- https://github.com/kevinhwang91/rnvimr

local M = {}

local extension_name = "rnvimr"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "kevinhwang91/rnvimr",
        cmd = { "RnvimrToggle" },
        keys = { "<F5>" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "rnvimr",
      })
    end,
    legacy_setup = {
      rnvimr_draw_border = 1,
      rnvimr_pick_enable = 1,
      rnvimr_bw_enable = 1,
      rnvimr_enable_ex = 0,
      rnvimr_hide_gitignore = 0,
      rnvimr_presets = { { width = 0.900, height = 0.900 } },
      -- rnvimr_ranger_cmd = 'ranger --cmd="set draw_borders both"'
      -- loaded_netrw = 1
      -- netrw_loaded_netrwPlugin = 1
    },
    keymaps = {
      n = {
        ["<F5>"] = ":RnvimrToggle<CR>",
      },
      t = {
        ["<F5>"] = "<C-\\><C-n>:RnvimrToggle<CR>",
      },
    },
  })
end

return M
