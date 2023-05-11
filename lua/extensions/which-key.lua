-- https://github.com/folke/which-key.nvim
local M = {}

local extension_name = "wk"

M.store_registered_key = "WHICH_KEY_REGISTERED"

M.opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

M.vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "folke/which-key.nvim",
        keys = { "<leader>", "g", "z", '"', "<C-r>", "m", "]", "[", "r" },
      }
    end,
    configure = function(_, fn)
      local wk = require("keys.wk")

      lvim.wk.mappings = vim.deepcopy(wk.mappings)
      lvim.wk.vmappings = vim.deepcopy(wk.vmappings)

      fn.add_disabled_filetypes({ "which_key" })
    end,
    inject_to_configure = function()
      return {
        which_key = require("which-key"),
      }
    end,
    setup = {
      plugins = {
        marks = false, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        presets = {
          operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g,
        },
      },
      operators = { gc = "Comments" },
      icons = {
        breadcrumb = lvim.ui.icons.ui.ChevronRight, -- symbol used in the command line area that shows your active key combo
        separator = lvim.ui.icons.ui.BoldArrowRight .. " ", -- symbol used between a key and it's label
        group = lvim.ui.icons.ui.Plus, -- symbol prepended to a group
      },
      popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
      },
      window = {
        border = lvim.ui.border, -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
      },
      triggers = { "<leader>", "g", "z", '"', "<C-r>", "m", "]", "[", "r" },
      show_help = false, -- show help message on the command line when the popup is visible
      show_keys = false, -- show the currently pressed key and its label as a message in the command line
    },
    on_setup = function(config, fn)
      local which_key = config.inject.which_key

      which_key.setup(config.setup)

      which_key.register(lvim.wk.mappings, M.opts)
      which_key.register(lvim.wk.vmappings, M.vopts)

      lvim.store.set_store(M.store_registered_key, true)

      if fn.is_extension_enabled("legendary_nvim") then
        require("legendary.integrations.which-key").bind_whichkey(lvim.wk.mappings, config.opts, false)
      end
    end,
    autocmds = {
      {
        "FileType",
        { group = "__which_key", pattern = "which_key", command = "nnoremap <silent> <buffer> <esc> <C-c><CR>" },
      },
    },
  })
end

return M
