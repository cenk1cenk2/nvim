local log = require("core.log")

local M = {}

--- Checks whether given lsp client is active.
---@param name string
---@return vim.lsp.Client | nil
function M.is_client_active(name)
  local clients = vim.lsp.get_clients()

  for _, client in pairs(clients) do
    if client.name == name then
      return client
    end
  end
end

---Get supported filetypes per server
---@param server_name string can be any server supported by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
function M.get_supported_filetypes(server_name)
  local status_ok, config = pcall(require, ("lspconfig.server_configurations.%s"):format(server_name))
  if not status_ok then
    return {}
  end

  return config.default_config.filetypes or {}
end

---@class LspToolMethods
---@field FORMATTER string
---@field LINTER string
M.METHODS = {
  FORMATTER = "formatters",
  LINTER = "linters",
}

function M.read_tools(method)
  return nvim.lsp.tools.by_ft[method]
end

function M.register_tools(method, configs, filetypes)
  if type(configs) == "string" then
    configs = { configs }
  end

  for _, ft in pairs(filetypes) do
    if nvim.lsp.tools.by_ft[method][ft] == nil then
      nvim.lsp.tools.by_ft[method][ft] = {}
    end

    vim.list_extend(nvim.lsp.tools.by_ft[method][ft], configs)
  end

  log:debug(("Registered the following method %s for %s: %s"):format(
    method,
    vim.inspect(vim.tbl_map(function(config)
      if type(config) == "string" then
        return config
      end

      return config.name
    end, configs)),
    table.concat(filetypes, ", ")
  ))
end

return M
