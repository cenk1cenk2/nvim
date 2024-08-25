local M = {}

local log = require("ck.log")
local utils = require("ck.lsp.utils")

---@param server_name string
---@return table
local function resolve_mason_config(server_name)
  local found, mason_config = pcall(require, "mason-lspconfig.server_configurations." .. server_name)
  if not found then
    return {}
  end

  local path = require("mason-core.path")
  local package_name = M.to_package_name(server_name)
  local install_dir = path.package_prefix(package_name)
  local conf = mason_config(install_dir)

  if OS_UNAME == "windows" and conf.cmd and conf.cmd[1] then
    local exepath = vim.fn.exepath(conf.cmd[1])
    if exepath ~= "" then
      conf.cmd[1] = exepath
    end
  end

  log:debug("Resolved mason configuration: %s", server_name)

  return conf or {}
end

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@param ... any config table [optional]
---@return table
local function resolve_config(server_name, ...)
  local config = require("ck.lsp.handlers").get()

  local ok, override = pcall(require, "ck.lsp.overrides." .. server_name)
  if ok then
    log:trace("Using custom configuration for requested server: %s", server_name)
    config = vim.tbl_deep_extend("force", config, override)
  else
    log:trace("Using default configuration for requested server: %s", server_name)
  end

  config = vim.tbl_deep_extend("force", config, ...)

  return config
end

---
---@param server_name string
---@param config table
local function launch_server(server_name, config)
  config.filetypes = config.filetypes or require("ck.lsp.utils").get_supported_filetypes(server_name)

  local filetypes = vim.tbl_filter(function(filetype)
    return not vim.tbl_contains(nvim.lsp.skipped_filetypes, filetype)
  end, config.filetypes)

  if #filetypes == 0 then
    log:error("LSP server does not have any filetypes remaining: %s -> before filter: %s", server_name, config.filetypes)

    return
  end

  config.filetypes = filetypes

  log:trace("LSP server is hooked for fts: %s -> %s", server_name, config.filetypes)

  xpcall(function()
    if require("ck.lsp.utils").is_client_active(server_name) then
      return
    end

    if type(config.override) == "function" then
      local override = config.override(config)

      log:trace("Server has a override function: %s", server_name)

      require("lspconfig")[server_name].setup(override)

      return
    end

    require("lspconfig")[server_name].setup(config)
  end, debug.traceback)
end

---@param server_name string
---@return string
function M.to_package_name(server_name)
  return require("mason-lspconfig.mappings.server").lspconfig_to_package[server_name] or server_name
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param user_config table? when available it will take predence over any default configurations
function M.setup(server_name, user_config)
  vim.validate({ name = { server_name, "string" } })
  user_config = user_config or {}

  if require("ck.lsp.utils").is_client_active(server_name) then
    return
  end

  local config = resolve_config(server_name, resolve_mason_config(server_name), user_config)

  launch_server(server_name, config)
end

return M
