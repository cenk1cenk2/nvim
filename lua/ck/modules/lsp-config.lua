local M = {}

local configs = require("lspconfig.configs")

function M.set_lsp_default_config(server_name, config)
  configs[server_name] = {
    default_config = config,
  }
end

function M.get_lsp_default_config(server_name)
  return configs[server_name].document_config.default_config
end

return M
