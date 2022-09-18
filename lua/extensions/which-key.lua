--
local M = {}

local extension_name = "wk"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "folke/which-key.nvim",
        config = function()
          require("utils.setup").packer_config "wk"
        end,
        disable = not config.active,
      }
    end,
    opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    vopts = {
      mode = "v", -- VISUAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    configure = function()
      local wk = require "keys.which-key"
      lvim.wk.mappings = vim.deepcopy(wk.mappings)
      lvim.wk.vmappings = vim.deepcopy(wk.vmappings)
    end,
    to_inject = function()
      return {
        which_key = require "which-key",
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
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+ ", -- symbol prepended to a group
      },
      popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
      },
      window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 0, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
      },
      triggers = { "<leader>", "g", "z", '"', "<C-r>", "m", "]", "[", "r" },
    },
    on_setup = function(config)
      local which_key = config.inject.which_key

      which_key.setup(config.setup)

      which_key.register(lvim.wk.mappings, config.opts)
      which_key.register(lvim.wk.vmappings, config.vopts)
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
