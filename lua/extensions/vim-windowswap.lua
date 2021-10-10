local M = {}

local extension_name = 'vim_windowswap'

function M.config()
  lvim.extensions[extension_name] = {active = true, on_config_done = nil}
end

function M.setup()

  vim.g.windowswap_map_keys = 0

  lvim.builtin.which_key.mappings['W'] = {':call WindowSwap#EasyWindowSwap()<CR>', 'move window'}

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done() end
end

return M
