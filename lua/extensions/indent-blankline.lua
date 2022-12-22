-- https://github.com/lukas-reineke/indent-blankline.nvim
local M = {}

local extension_name = "indent_blankline"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      return {
        use_treesitter = true,
        show_current_context = true,
        show_first_indent_level = false,
        filetype_exclude = lvim.disabled_filetypes,
        enabled = true,
        show_trailing_blankline_indent = true,
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
      }
    end,
    on_setup = function(config)
      require("indent_blankline").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["i"] = { ":IndentBlanklineToggle<CR>", "toggle indentation guides" },
        },
      }
    end,
  })
end

return M
