local M = {}

local configs = require("lspconfig.configs")

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
  local ok, config = pcall(require, ("lspconfig.server_configurations.%s"):format(server_name))
  if not ok then
    return {}
  end

  return config.default_config.filetypes or {}
end

--- Executes LSP command synchronylousy against the given buffer.
---@param bufnr number
---@param command lsp.Command
function M.lsp_execute_command(bufnr, command)
  vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", command)
end

--- Applies LSP edit in multiple formats.
---@param result lsp.WorkspaceEdit | lsp.Command
function M.apply_lsp_edit(result)
  if result.edit then
    vim.lsp.util.apply_workspace_edit(result.edit, "utf-8")

    return
  elseif result.command then
    M.lsp_execute_command(0, result.command)

    return
  elseif result.changes then
    for uri, changes in pairs(result.changes) do
      local bufnr = vim.uri_to_bufnr(uri)
      vim.lsp.util.apply_text_edits(changes, bufnr, "utf-8")
    end

    return
  end

  M.lsp_execute_command(0, result)
end

return M
