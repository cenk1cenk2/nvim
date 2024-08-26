-- https://github.com/lukas-reineke/indent-blankline.nvim
local M = {}

M.name = "lukas-reineke/indent-blankline.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      ---@type ibl.config
      return {
        indent = { highlight = "IndentBlankLineChar", char = nvim.ui.icons.LineLeft },
        whitespace = {
          highlight = "IndentBlankLineChar",
          remove_blankline_trail = false,
        },
        scope = {
          enabled = true,
          char = nvim.ui.icons.LineLeft,
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
          filetypes = nvim.disabled_filetypes,
        },
      }
    end,
    on_setup = function(c)
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)

      require("ibl").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "i" }),
          function()
            vim.cmd([[IBLToggle]])
          end,
          desc = "toggle indentation guides",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "I" }),
          function()
            vim.cmd([[IBLToggleScope]])
          end,
          desc = "toggle indentation guides in scope",
        },
      }
    end,
  })
end

return M
