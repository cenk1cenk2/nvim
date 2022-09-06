local M = {}
local configs = require "lspconfig/configs"
local Log = require "lvim.core.log"

function M.set_lsp_default_config(server_name, config)
  configs[server_name] = {
    default_config = config,
  }
end

function M.get_lsp_default_config(server_name)
  return configs[server_name].document_config.default_config
end

function M.set_mason_registry(server_name, path)
  local ok, registry = pcall(require, "mason-registry.index")

  if not ok then
    Log:warn(("Mason registry is not available while setting server: %s").format(server_name))

    return
  end

  registry[server_name] = path
end

function M.setup() end

return M
