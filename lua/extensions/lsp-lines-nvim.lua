local M = {}

local extension_name = "lsp_lines_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
  }
end

function M.setup()
  local extension = require "lsp_lines"
  extension.register_lsp_virtual_lines()

  vim.diagnostic.config {
    virtual_text = false,
  }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
