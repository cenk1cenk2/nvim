local M = {}

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
