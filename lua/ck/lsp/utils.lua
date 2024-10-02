local M = {}

--- Checks whether given lsp client is active.
---@param name string
---@return vim.lsp.Client[] | nil
function M.is_client_active(name)
  local clients = vim.lsp.get_clients({ name = name })

  if #clients > 0 then
    return unpack(clients)
  end
end

---Get supported filetypes per server
---@param server_name string can be any server supported by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
function M.get_supported_filetypes(server_name)
  local ok, config = pcall(require, ("lspconfig.configs.%s"):format(server_name))
  if not ok then
    return {}
  end

  return config.default_config.filetypes or {}
end

return M
