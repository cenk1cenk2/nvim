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

--- Returns the matching LSP servers for filetype.
---@param filetype string
---@return vim.lsp.Client[]
function M.get_clients_by_ft(filetype)
  local matches = {}
  local clients = vim.lsp.get_clients()
  for _, client in pairs(clients) do
    local supported_filetypes = client.config.filetypes or {}
    if vim.tbl_contains(supported_filetypes, filetype) then
      table.insert(matches, client)
    end
  end
  return matches
end

--- Returns the LSP client capabilities.
---@param client_id integer
---@return lsp.ServerCapabilities | nil
function M.get_client_capabilities(client_id)
  local client = vim.lsp.get_client_by_id(tonumber(client_id))

  if not client then
    error("Unable to find given LSP client.")
    return
  end

  local enabled_caps = {}
  for capability, status in pairs(client.server_capabilities or client.resolved_capabilities) do
    if status == true then
      table.insert(enabled_caps, capability)
    end
  end

  return enabled_caps
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

---Get supported servers per filetype
---@param filter { filetype: string | string[] }?: (optional) Used to filter the list of server names.
---@return string[] list of names of supported servers
function M.get_supported_servers(filter)
  local _, supported_servers = pcall(function()
    return require("mason-lspconfig").get_available_servers(filter)
  end)
  return supported_servers or {}
end

---Get all supported filetypes by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
function M.get_all_supported_filetypes()
  local status_ok, filetype_server_map = pcall(require, "mason-lspconfig.mappings.filetype")
  if not status_ok then
    return {}
  end
  return vim.tbl_keys(filetype_server_map or {})
end

---@enum LspToolMethods
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
