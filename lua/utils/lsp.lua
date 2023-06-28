local M = {}

local Log = require("lvim.core.log")

function M.lsp_execute_command(bn, command)
  vim.lsp.buf_request_sync(bn, "workspace/executeCommand", command)
end

function M.apply_lsp_edit(result)
  if result.changes then
    Log:warn(("Changes are not supported: %s"):format(vim.inspect(result)))

    return
  end

  if result.edit or type(result.command) == "table" then
    if result.edit then
      vim.lsp.util.apply_workspace_edit(result.edit, "utf-8")

      return
    end

    if type(result.command) == "table" then
      M.lsp_execute_command(0, result.command)

      return
    end
  end

  M.lsp_execute_command(0, result)
end

return M
