-- https://github.com/folke/which-key.nvim
local M = {}

M.name = "folke/which-key.nvim"

M.opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "folke/which-key.nvim",
        keys = { "<leader>", "g", "z", '"', "<C-r>", "m", "]", "[", "r", "d", "c", "r", "y", "p", "P" },
        event = "UIEnter",
      }
    end,
    configure = function(_, fn)
      lvim.wk = vim.list_extend(lvim.wk, require("core.keys.wk").setup(fn))

      fn.add_disabled_filetypes({ "which_key" })
    end,
    setup = function()
      return {
        preset = "helix",
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
          rules = false,
          breadcrumb = lvim.ui.icons.ui.DoubleChevronRight, -- symbol used in the command line area that shows your active key combo
          separator = lvim.ui.icons.ui.DoubleChevronRight .. " ", -- symbol used between a key and it's label
          group = lvim.ui.icons.ui.Plus, -- symbol prepended to a group
        },
        win = {
          -- don't allow the popup to overlap with the cursor
          no_overlap = true,
          -- width = 1,
          -- height = { min = 4, max = 25 },
          -- col = 0,
          -- row = math.huge,
          border = lvim.ui.border,
          padding = { 0, 2 }, -- extra window padding [top/bottom, right/left]
          title = true,
          title_pos = "center",
          zindex = 1000,
          -- Additional vim.wo and vim.bo options
          bo = {},
          wo = {
            -- winblend = 95, -- value between 0-100 0 for fully opaque and 100 for fully transparent
          },
        },
        layout = {
          height = { min = 4 }, -- min and max height of the columns
          width = { min = 20 }, -- min and max width of the columns
          spacing = 4, -- spacing between columns
          align = "center", -- align columns left, center or right
        },
        triggers = {
          { "<auto>", mode = { "n", "i", "x", "s", "o", "t", "c" } },
          -- { "<leader>" },
          -- { "g" },
          -- { "z" },
          -- { '"' },
          -- { "<C-r>" },
          -- { "m" },
          -- { "]" },
          -- { "[" },
          -- { "r" },
        },
        show_help = false, -- show help message on the command line when the popup is visible
        show_keys = false, -- show the currently pressed key and its label as a message in the command line
      }
    end,
    on_setup = function(c)
      local which_key = require("which-key")

      which_key.setup(c)

      which_key.add(lvim.wk)
    end,
    autocmds = function()
      return {
        {
          event = "FileType",
          group = "__which_key",
          pattern = "which_key",
          command = "nnoremap <silent> <buffer> <esc> <C-c><CR>",
        },
      }
    end,
  })
end

return M
