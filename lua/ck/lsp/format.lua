local M = {}
local log = require("ck.log")

local group = "lsp_format_on_save"

--- Creates the autocommand for format on save.
function M.enable_format_on_save()
  vim.api.nvim_create_augroup(group, { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = nvim.lsp.tools.format.pattern,
    callback = function(args)
      nvim.lsp.fn.format({ bufnr = args.bufnr })
    end,
  })

  log:debug("Enabled format on save.")
end

--- Removes the autocommand for format on save.
function M.disable_format_on_save()
  require("ck.setup").clear_augroup(group)

  log:debug("Disabled format on save.")
end

---@return boolean
function M.should_format_on_save()
  return require("ck.setup").get_augroup(group) ~= nil
end

--- Toggles the autocommand for format on save.
function M.toggle_format_on_save()
  if M.should_format_on_save() then
    M.disable_format_on_save()
    log:info("Disabled format on save.")
  else
    M.enable_format_on_save()
    log:info("Enabled format on save.")
  end
end

---@alias FormatFilterFn fun(client: vim.lsp.Client): boolean

---filter passed to vim.lsp.buf.format
---@type FormatFilterFn
function M.filter(client)
  local registered = nvim.lsp.tools.list_registered.formatters(0)

  if #registered > 0 then
    return client.name == nvim.lsp.tools.clients[M.METHODS.FORMATTER]
  elseif client.supports_method("textDocument/formatting") then
    return true
  end

  return false
end

function M.setup()
  if nvim.lsp.tools.format.enable then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

return M
