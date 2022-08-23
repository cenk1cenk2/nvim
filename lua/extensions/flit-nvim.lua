local M = {}

local extension_name = "flit_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {
      multiline = true,
      eager_ops = false, -- jump right to the ([count]th) target (no labels)
      keymaps = { f = "f", F = "F", t = "t", T = "T" },
    },
  }
end

function M.setup()
  local extension = require "flit"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
