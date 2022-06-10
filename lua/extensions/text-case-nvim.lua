local M = {}

local extension_name = "text_case_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      prefix = "gs",
    },
  }
end

function M.setup()
  local extension = require "textcase"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
