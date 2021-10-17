local M = {}

local extension_name = "undotree"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }
end

function M.setup()
  lvim.builtin.which_key.mappings["u"] = { ":UndotreeToggle<CR>", "toggle undo tree" }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
