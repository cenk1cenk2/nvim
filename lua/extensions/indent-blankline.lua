-- https://github.com/lukas-reineke/indent-blankline.nvim
local setup = require "utils.setup"

local M = {}

local extension_name = "indent_blankline"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
          require("utils.setup").packer_config "indent_blankline"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      use_treesitter = true,
      show_current_context = true,
      show_first_indent_level = false,
      filetype_exclude = {
        "startify",
        "far",
        "gitcommit",
        "terminal",
        "floaterm",
        "NvimTree",
        "neo-tree",
        "dashboard",
        "alpha",
        "toggleterm",
        "packer",
        "lspinfo",
        "lsp-installer",
      },
      enabled = true,
      show_trailing_blankline_indent = false,
      char = "│",
      space_char_highlight_list = {},
      context_patterns = {
        "class",
        "return",
        "function",
        "method",
        "^if",
        "^while",
        "jsx_element",
        "^for",
        "^object",
        "^table",
        "block",
        "arguments",
        "if_statement",
        "else_clause",
        "jsx_element",
        "jsx_self_closing_element",
        "try_statement",
        "catch_clause",
        "import_statement",
        "operation_type",
      },
    },
    on_setup = function(config)
      require("indent_blankline").setup(config.setup)
    end,
    wk = {
      ["a"] = {
        ["i"] = { ":IndentBlanklineToggle<CR>", "toggle indentation guides" },
      },
    },
  })
end

return M
