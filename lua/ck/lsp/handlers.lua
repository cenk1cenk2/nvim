local M = {}

local setup = require("ck.setup")
local log = require("ck.log")

---@alias LspOnCallback fun(client: vim.lsp.Client, bufnr: number)

function M.setup()
  vim.diagnostic.config(nvim.lsp.diagnostics)

  -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, nvim.lsp.float)
  -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, nvim.lsp.float)
end

---
---@return table
function M.get()
  return {
    on_attach = M.on_attach,
    on_init = M.on_init,
    on_exit = M.on_exit,
    capabilities = M.capabilities(),
  }
end

--- Returns default capabilities for client.
---@return lsp.ClientCapabilities
function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  -- comes from LspRename custom function
  capabilities.workspace.fileOperations = {
    willRename = true,
  }

  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

---@type LspOnCallback
function M.overwrite_capabilities_with_no_formatting(client, _)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

---@type LspOnCallback
function M.on_exit(client, bufnr)
  if #nvim.lsp.on_exit_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_exit) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_exit")
  end
end

---@type LspOnCallback
function M.on_init(client, bufnr)
  if #nvim.lsp.on_init > 0 then
    for _, cb in pairs(nvim.lsp.on_init) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_init_callbacks")
  end
end

---@type LspOnCallback
function M.on_attach(client, bufnr)
  if #nvim.lsp.on_attach_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_attach_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_attach_callbacks")
  end

  if nvim.lsp.codelens.refresh then
    M.attach_codelens(client, bufnr)
  end

  if nvim.lsp.inlay_hints.enabled then
    M.attach_inlay_hints(client, bufnr)
  end

  setup.load_keymaps(nvim.lsp.keymaps, { buffer = bufnr })
  for k, v in pairs(nvim.lsp.buffer_options) do
    vim.api.nvim_set_option_value(k, v, { buf = bufnr })
  end
end

---@type LspOnCallback
function M.attach_codelens(client, bufnr)
  local method = "textDocument/codeLens"
  local ok, codelens_supported = pcall(function()
    return client.supports_method(method)
  end)

  if not ok or not codelens_supported then
    return
  end

  local group = "lsp_codelens_refresh"
  local events = { "LspAttach", "InsertLeave", "BufReadPost" }

  local ok, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = group,
    buffer = bufnr,
    event = events,
  })

  if ok and #autocmds > 0 then
    return
  end

  local augroup = vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_create_autocmd(events, {
    group = group,
    buffer = bufnr,
    callback = function()
      vim.schedule(function()
        if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) == 0 then
          pcall(vim.lsp.codelens.refresh)
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) == 0 then
        vim.api.nvim_del_augroup_by_id(augroup)
      end
    end,
  })
end

---@type LspOnCallback
function M.attach_inlay_hints(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
  end
end

return M
