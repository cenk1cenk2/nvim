local M = {}

local extension_name = "lsp_lines_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      normal_mode = {
        ["gL"] = { require("lsp_lines").toggle, { noremap = false, silent = true, desc = "Toggle lsp_lines" } },
      },
    },
  }
end

function M.setup()
  local extension = require "lsp_lines"
  extension.setup()

  vim.diagnostic.config {
    virtual_text = false,
  }

  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
