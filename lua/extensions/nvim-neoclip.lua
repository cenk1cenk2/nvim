local M = {}

local extension_name = 'neoclip'

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      history = 1000,
      filter = nil,
      preview = true,
      default_register = 'r',
      content_spec_column = false,
      on_paste = {set_reg = false},
      keys = {i = {select = '<cr>', paste = '<c-p>', paste_behind = '<c-k>'}, n = {select = '<cr>', paste = 'p', paste_behind = 'P'}}
    }
  }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings['y'] = {':Telescope neoclip<CR>', 'yank registers'}

  require('telescope').load_extension('neoclip')

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done(extension) end

end

return M