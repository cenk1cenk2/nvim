local M = {}

local extension_name = "neogen"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil, setup = {
    enabled = true,
  } }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings["l"]["j"] = { ':lua require("neogen").generate()<CR>', "generate documentation" }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
