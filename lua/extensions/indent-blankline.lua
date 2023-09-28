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
        indent = { highlight = "IndentBlankLineChar", char = lvim.ui.icons.LineLeft },
        whitespace = {
          highlight = "IndentBlankLineChar",
          remove_blankline_trail = false,
        },
        scope = {
          enabled = true,
          char = lvim.ui.icons.LineLeft,
          show_start = false,
          show_end = false,
          injected_languages = true,
          highlight = "IndentBlanklineContextChar",
          priority = 1024,
          include = {
            node_type = {
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
          exclude = {
            language = {},
            node_type = {
              ["*"] = {
                "source_file",
                "program",
              },
              lua = {
                "chunk",
              },
              python = {
                "module",
              },
            },
          },
        },
        exclude = {
          filetypes = lvim.disabled_filetypes,
        },
      }
    end,
    on_setup = function(config)
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)

      require("ibl").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["i"] = { ":IBLToggle<CR>", "toggle indentation guides" },
          ["I"] = { ":IBLToggleScope<CR>", "toggle indentation guides" },
        },
      }
    end,
  })
end

return M
