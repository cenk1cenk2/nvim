local M = {}

local extension_name = "rust_tools_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {},
  }
end

function M.setup() end

return M
