local M = {}

local extension_name = "document_color_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      mode = "background", -- "background" | "foreground" | "single"
    },
  }
end

function M.setup()
  local extension = require "document-color"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
