local M = {}

M.update_lightbulb = function()
  local extension_name = "nvim_lightbulb"

  local extension = require "nvim-lightbulb"

  return extension.update_lightbulb(lvim.extensions[extension_name].setup)
end

M.setup = function() end

return M
