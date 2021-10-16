local M = {}

local extension_name = 'hop'

function M.config()
  lvim.extensions[extension_name] = {active = true, on_config_done = nil, keymaps = {normal_mode = {['s'] = ':HopChar2<cr>', ['S'] = ':HopWord<cr>'}}}

  require('lvim.keymappings').append_to_defaults(lvim.extensions[extension_name].keymaps)
end

function M.setup()
  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done() end
end

return M
