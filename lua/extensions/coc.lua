local M = {}

local extension_name = "coc"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }
end

function M.setup()
  vim.g.coc_start_at_startup = true

  vim.g.coc_global_extensions = {
    "coc-lists",
    "coc-marketplace",
    "coc-gitignore",
    "coc-gist",
  }

  vim.g.coc_suggest_disable = 1

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
