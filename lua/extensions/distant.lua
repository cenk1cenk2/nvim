local M = {}

local extension_name = "distant"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }
end

function M.setup()
  local extension = require(extension_name)

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], {
    setup = {
      ["*"] = require("distant.settings").chip_default(),
    },
  })

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
