local M = {}

local extension_name = "vim_better_whitespace"

function M.config()
  lvim.extensions[extension_name] = { active = false, on_config_done = nil }
end

function M.setup()
  vim.g.better_whitespace_enabled = 1
  vim.g.better_whitespace_filetypes_blacklist = {
    "far",
    "diff",
    "gitcommit",
    "help",
    "dashboard",
    "alpha",
    "spectre_panel",
    "LspTrouble",
    "TelescopePrompt",
    "floaterm",
    "toggleterm",
  }
  vim.g.strip_whitespace_on_save = 1
  vim.g.strip_whitespace_confirm = 0

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
