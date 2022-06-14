local M = {}

local extension_name = "vim_jinja2_syntax"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }
end

function M.setup()
  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M