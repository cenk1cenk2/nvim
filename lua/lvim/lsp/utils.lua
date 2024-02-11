local Log = require("lvim.core.log")

local M = {}

function M.is_client_active(name)
  local clients = vim.lsp.get_clients()

  for _, client in pairs(clients) do
    if client.name == name then
      return client
    end
  end
end

function M.get_clients_by_ft(filetype)
  local matches = {}
  local clients = vim.lsp.get_clients()
  for _, client in pairs(clients) do
    local supported_filetypes = client.config.filetypes or {}
    if vim.tbl_contains(supported_filetypes, filetype) then
      table.insert(matches, client)
    end
  end
  return matches
end

function M.get_client_capabilities(client_id)
  local client = vim.lsp.get_client_by_id(tonumber(client_id))

  if not client then
    error("Unable to determine client_id")
    return
  end

  local enabled_caps = {}
  for capability, status in pairs(client.server_capabilities or client.resolved_capabilities) do
    if status == true then
      table.insert(enabled_caps, capability)
    end
  end

  return enabled_caps
end

---Get supported filetypes per server
---@param server_name string can be any server supported by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
function M.get_supported_filetypes(server_name)
  local status_ok, config = pcall(require, ("lspconfig.server_configurations.%s"):format(server_name))
  if not status_ok then
    return {}
  end

  return config.default_config.filetypes or {}
end

---Get supported servers per filetype
---@param filter { filetype: string | string[] }?: (optional) Used to filter the list of server names.
---@return string[] list of names of supported servers
function M.get_supported_servers(filter)
  local _, supported_servers = pcall(function()
    return require("mason-lspconfig").get_available_servers(filter)
  end)
  return supported_servers or {}
end

---Get all supported filetypes by nvim-lsp-installer
---@return string[] supported filestypes as a list of strings
function M.get_all_supported_filetypes()
  local status_ok, filetype_server_map = pcall(require, "mason-lspconfig.mappings.filetype")
  if not status_ok then
    return {}
  end
  return vim.tbl_keys(filetype_server_map or {})
end

function M.setup_codelens_refresh(client, bufnr)
  local status_ok, codelens_supported = pcall(function()
    return client.supports_method("textDocument/codeLens")
  end)

  if not status_ok or not codelens_supported then
    return
  end

  local group = "lsp_code_lens_refresh"
  local cl_events = { "LspAttach", "InsertLeave" }

  local ok, cl_autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = group,
    buffer = bufnr,
    event = cl_events,
  })

  if ok and #cl_autocmds > 0 then
    return
  end

  vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_create_autocmd(cl_events, {
    group = group,
    buffer = bufnr,
    callback = function()
      pcall(vim.lsp.codelens.refresh)
    end,
  })
end

function M.setup_inlay_hints(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(bufnr, false)
  end
end

---filter passed to vim.lsp.buf.format
---@param client table client attached to a buffer
---@return boolean if client matches
function M.format_filter(client)
  -- local available_formatters = lvim.lsp.tools.list_registered.formatters(0)

  -- if #available_formatters > 0 then
  --   return client.name == lvim.lsp.tools.clients[M.METHODS.FORMATTER]
  if client.supports_method("textDocument/formatting") then
    return true
  end

  return false
end

M.METHODS = {
  FORMATTER = "formatters",
  LINTER = "linters",
}

function M.read_tools(method)
  return lvim.lsp.tools.by_ft[method]
end

function M.register_tools(method, configs, filetypes)
  if type(configs) == "string" then
    configs = { configs }
  end

  for _, ft in pairs(filetypes) do
    if lvim.lsp.tools.by_ft[method][ft] == nil then
      lvim.lsp.tools.by_ft[method][ft] = {}
    end

    vim.list_extend(lvim.lsp.tools.by_ft[method][ft], configs)
  end

  Log:debug(("Registered the following method %s for %s: %s"):format(
    method,
    vim.inspect(vim.tbl_map(function(config)
      if type(config) == "string" then
        return config
      end

      return config.name
    end, configs)),
    table.concat(filetypes, ", ")
  ))
end

return M
