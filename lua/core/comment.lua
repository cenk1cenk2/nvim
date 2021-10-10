local M = {}

local extension_name = 'nvim_comment'

function M.config()
  lvim.builtin[extension_name] = {
    active = true,
    on_config_done = nil,
    -- Linters prefer comment and line to have a space in between markers
    setup = {
      -- Linters prefer comment and line to have a space in between markers
      marker_padding = true,
      -- should comment out empty or whitespace only lines
      comment_empty = true,
      -- Should key mappings be created
      create_mappings = true,
      -- Normal mode mapping left hand side
      line_mapping = 'gcc',
      -- Visual/Operator mapping left hand side
      operator_mapping = 'gc',
      -- Hook function to call before commenting takes place
      hook = function()
        if vim.api.nvim_buf_get_option(0, 'filetype') == 'vue' or vim.api.nvim_buf_get_option(0, 'filetype') == 'javascriptreact' or vim.api.nvim_buf_get_option(0, 'filetype') ==
          'typescriptreact' then require('ts_context_commentstring.internal').update_commentstring() end
      end
    }
  }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.builtin[extension_name].setup)
  if lvim.builtin[extension_name].on_config_done then lvim.builtin[extension_name].on_config_done(extension) end
end

return M
