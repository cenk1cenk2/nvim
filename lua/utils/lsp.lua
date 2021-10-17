local M = {}

function M.lsp_execute_command(bn, command)
  vim.lsp.buf_request_sync(bn, "workspace/executeCommand", command)
end

function M.apply_lsp_edit(result)
  if result.edit or type(result.command) == "table" then
    if result.edit then
      vim.lsp.util.apply_workspace_edit(result.edit)
    end
    if type(result.command) == "table" then
      M.lsp_execute_command(0, result.command)
    end
  else
    M.lsp_execute_command(0, result)
  end
end

return M
