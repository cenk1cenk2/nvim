local M = {}

local extension_name = "octo"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil, setup = {} }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
