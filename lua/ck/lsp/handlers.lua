local M = {}

local log = require("ck.log")

---@alias LspOnCallback fun(client: vim.lsp.Client, bufnr: number)
---@alias NvimLspFeaturePredicate boolean | fun(client: vim.lsp.Client, bufnr: number): boolean

function M.setup()
  vim.diagnostic.config(nvim.lsp.diagnostics)

  vim.lsp.config("*", M.get())

  --- TODO: make this configurable as well in the future? but this is not on attach this is more like a global
  vim.lsp.inline_completion.enable(require("ck.setup").evaluate_property(nvim.lsp.features.inline_completion.enabled))

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method("textDocument/foldingRange") then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        -- vim.wo[win][0].foldtext = "v:lua.vim.lsp.foldtext()"
      end
    end,
  })
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

  local cok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if cok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  local bok, blink = pcall(require, "blink-cmp")
  if bok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  return capabilities
end

---@type LspOnCallback
function M.overwrite_capabilities_with_no_on_type_formatting(client, _)
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end

---@type LspOnCallback
function M.overwrite_capabilities_with_no_formatting(client, _)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

---@type LspOnCallback
function M.overwrite_capabilities_with_formatting(client, _)
  client.server_capabilities.documentFormattingProvider = true
  client.server_capabilities.documentRangeFormattingProvider = true
end

---@type LspOnCallback
function M.on_exit(client, bufnr)
  if #nvim.lsp.on_exit_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_exit_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_exit_callbacks.")
  end
end

---@type LspOnCallback
function M.on_init(client, bufnr)
  if #nvim.lsp.on_init_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_init_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_init_callbacks.")
  end
end

---@type LspOnCallback
function M.on_attach(client, bufnr)
  require("ck.keys.lsp").on_attach(client, bufnr)

  if M.is_lsp_feature_enabled(nvim.lsp.features.codelens.enabled, client, bufnr) then
    M.attach_codelens(client, bufnr)
  end

  if M.is_lsp_feature_enabled(nvim.lsp.features.inlay_hints.enabled, client, bufnr) then
    M.attach_inlay_hints(client, bufnr)
  end

  if M.is_lsp_feature_enabled(nvim.lsp.features.on_type_formatting.enabled, client, bufnr) then
    vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
  end

  if #nvim.lsp.on_attach_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_attach_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_attach_callbacks.")
  end
end

---
---@param enabled NvimLspFeaturePredicate
function M.is_lsp_feature_enabled(enabled, ...)
  return (type(enabled) == "boolean" and enabled) or (type(enabled) == "function" and enabled(...)) or false
end

---@type LspOnCallback
function M.attach_codelens(client, bufnr)
  local method = "textDocument/codeLens"
  local ok, codelens_supported = pcall(function()
    return client:supports_method(method)
  end)

  if not ok or not codelens_supported then
    return
  end

  local group = "lsp_codelens_refresh"
  local events = { "LspAttach", "InsertLeave", "BufEnter", "CursorHold" }

  local autocmd_ok, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = group,
    buffer = bufnr,
    event = events,
  })

  if autocmd_ok and #autocmds > 0 then
    return
  end

  local augroup = vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_create_autocmd(events, {
    group = group,
    buffer = bufnr,
    callback = function()
      vim.schedule(function()
        if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) == 0 then
          pcall(vim.lsp.codelens.refresh, { bufnr = bufnr })
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      vim.api.nvim_del_augroup_by_id(augroup)
    end,
  })
end

---@type LspOnCallback
function M.attach_inlay_hints(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(nvim.lsp.features.inlay_hints.toggled, { bufnr = bufnr })
  end
end

---@type LspOnCallback
function M.attach_on_type_formatting(client, bufnr)
  -- if client.server_capabilities.onTypeFormatting then
  vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
  -- end
end

return M
