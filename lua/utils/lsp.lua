local M = {}

function M.lsp_execute_command(bn, command)
  vim.lsp.buf_request_sync(bn, "workspace/executeCommand", command)
end

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
