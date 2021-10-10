local M = {}

local extension_name = 'vim_maximizer'

function M.config()
  lvim.extensions[extension_name] = {active = true, on_config_done = nil}
end

function M.setup()
  vim.g.maximizer_set_default_mapping = 0

  require('utils.command').set_option({winminheight = 0, winminwidth = 0})

  lvim.builtin.which_key.mappings['M'] = {':MaximizerToggle<CR>', 'maximize current window'}

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done() end
end

return M
