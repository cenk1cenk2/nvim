local M = {}

local extension_name = "lsp_lines_nvim"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }

  local status_ok, _ = pcall(require, "lsp_lines")
  if not status_ok then
    return
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], {
    keymaps = {
      normal_mode = {
        ["gL"] = { require("lsp_lines").toggle, { desc = "Toggle LSP Lines" } },
      },
    },
  })
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
