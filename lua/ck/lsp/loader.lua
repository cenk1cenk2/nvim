local M = {}

local log = require("ck.log")

---
---@param server_name string
---@return vim.lsp.ClientConfig | nil
local function launch_server(server_name)
  log:trace("LSP server is configured: %s", server_name)

  local config = vim.lsp.config[server_name] or {}

  if type(config.override) == "function" then
    config = config.override(config) or {}

    vim.lsp.config(server_name, config)

    log:trace("Server has a override function: %s", server_name)
  end

  if type(config.condition) == "function" then
    local condition = config.condition(config)

    if not condition then
      log:trace("Server condition enable is skipped: %s", server_name)

      return
    end
  end

  vim.lsp.enable(server_name)

  return config
end

---Setup a language server by providing a name
function M.setup()
  for _, server_name in ipairs(nvim.lsp.servers) do
    launch_server(server_name)
  end
end

return M
