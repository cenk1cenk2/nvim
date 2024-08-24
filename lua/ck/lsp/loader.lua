local M = {}

local log = require("ck.log")
local nvim_lsp_utils = require("ck.lsp.utils")

local function resolve_mason_config(server_name)
  local found, mason_config = pcall(require, "mason-lspconfig.server_configurations." .. server_name)
  if not found then
    return {}
  end

  local server_mapping = require("mason-lspconfig.mappings.server")
  local path = require("mason-core.path")
  local pkg_name = server_mapping.lspconfig_to_package[server_name]
  local install_dir = path.package_prefix(pkg_name)
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
  local defaults = {
    on_attach = require("ck.lsp").common_on_attach,
    on_init = require("ck.lsp").common_on_init,
    on_exit = require("ck.lsp").common_on_exit,
    capabilities = require("ck.lsp").common_capabilities(),
  }

  local has_custom_provider, custom_config = pcall(require, "ck.lsp.overrides." .. server_name)
  if has_custom_provider then
    log:trace("Using custom configuration for requested server: %s", server_name)
    defaults = vim.tbl_deep_extend("force", defaults, custom_config)
  else
    log:trace("Using default configuration for requested server: %s", server_name)
  end

  defaults = vim.tbl_deep_extend("force", defaults, ...)

  return defaults
end

local function launch_server(server_name, config)
  local ft = config.filetypes or require("ck.lsp.utils").get_supported_filetypes(server_name)
  log:trace(("%s is hooked for fts: %s"):format(server_name, vim.inspect(ft)))

  xpcall(function()
    if M.has_setup(server_name) then
      return
    end

    if type(config.override) == "function" then
      local override = config.override(config)

      if override then
        require("lspconfig")[server_name].setup(override)
      end

      return
    end

    require("lspconfig")[server_name].setup(config)
  end, debug.traceback)
end

function M.has_setup(server_name)
  if nvim_lsp_utils.is_client_active(server_name) then
    return true
  end

  return false
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param user_config table? when available it will take predence over any default configurations
function M.setup(server_name, user_config)
  vim.validate({ name = { server_name, "string" } })
  user_config = user_config or {}

  if M.has_setup(server_name) then
    return
  end

  local server_mapping = require("mason-lspconfig.mappings.server")
  local registry = require("mason-registry")

  local pkg_name = server_mapping.lspconfig_to_package[server_name]
  if not pkg_name then
    local config = resolve_config(server_name, user_config)

    launch_server(server_name, config)

    return
  end

  if not registry.is_installed(pkg_name) then
    if not vim.tbl_contains(nvim.lsp.skipped_servers, server_name) then
      log:debug("Language server should be automatically installed: %s", server_name)
      vim.notify_once(string.format("Installation in progress for [%s]", server_name), vim.log.levels.INFO)

      local pkg = registry.get_package(pkg_name)
      pkg:install():once("closed", function()
        if pkg:is_installed() then
          vim.schedule(function()
            vim.notify_once(string.format("Installation complete for [%s]", server_name), vim.log.levels.INFO)
            -- mason config is only available once the server has been installed
            local config = resolve_config(server_name, resolve_mason_config(server_name), user_config)

            launch_server(server_name, config)
          end)
        end
      end)

      return
    else
      log:debug("Language server will not be automatically installed: %s", server_name)
    end
  end

  local config = resolve_config(server_name, resolve_mason_config(server_name), user_config)

  launch_server(server_name, config)
end

return M
