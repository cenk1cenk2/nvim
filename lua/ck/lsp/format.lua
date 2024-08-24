local M = {}
local log = require("ck.log")

--- Creates the autocommand for format on save.
function M.enable_format_on_save()
  vim.api.nvim_create_augroup("lsp_format_on_save", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = "lsp_format_on_save",
    pattern = nvim.lsp.format_on_save.pattern,
    callback = function(args)
      nvim.lsp.fn.format({ bufnr = args.bufnr })
    end,
  })
  log:debug("enabled format-on-save")
end

--- Removes the autocommand for format on save.
function M.disable_format_on_save()
  require("ck.setup").clear_augroup("lsp_format_on_save")
  log:debug("disabled format-on-save")
end

--- Toggles the autocommand for format on save.
function M.toggle_format_on_save()
  local exists, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = "lsp_format_on_save",
    event = "BufWritePre",
  })
  if not exists or #autocmds == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

---filter passed to vim.lsp.buf.format
---@param client vim.lsp.Client client attached to a buffer
---@return boolean if client matches
function M.format_filter(client)
  -- local available_formatters = nvim.lsp.tools.list_registered.formatters(0)

  -- if #available_formatters > 0 then
  --   return client.name == nvim.lsp.tools.clients[M.METHODS.FORMATTER]
  if client.supports_method("textDocument/formatting") then
    return true
  end

  return false
end

function M.setup()
  if nvim.lsp.format_on_save.enable then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

return M
