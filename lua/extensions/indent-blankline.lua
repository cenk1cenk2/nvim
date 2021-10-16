local M = {}

local extension_name = 'indent_blankline'

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      use_treesitter = true,
      show_current_context = true,
      show_first_indent_level = false,
      filetype_exclude = {'startify', 'far', 'gitcommit', 'terminal', 'floaterm', 'NvimTree', 'dashboard'},
      enabled = true,
      show_trailing_blankline_indent = false,
      char = '┆',
      space_char_highlight_list = {},
      context_patterns = {
        'class',
        'return',
        'function',
        'method',
        '^if',
        '^while',
        'jsx_element',
        '^for',
        '^object',
        '^table',
        'block',
        'arguments',
        'if_statement',
        'else_clause',
        'jsx_element',
        'jsx_self_closing_element',
        'try_statement',
        'catch_clause',
        'import_statement',
        'operation_type'
      }
    }
  }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings['a']['i'] = {':IndentBlanklineToggle<CR>', 'indentation guides'}

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done(extension) end
end

return M
