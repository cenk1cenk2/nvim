local M = {}

local Log = require("lvim.core.log")
local lvim_lsp_utils = require("lvim.lsp.utils")
local is_windows = vim.loop.os_uname().version:match("Windows")

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
  if is_windows and conf.cmd and conf.cmd[1] then
    local exepath = vim.fn.exepath(conf.cmd[1])
    if exepath ~= "" then
      conf.cmd[1] = exepath
    end
  end

  Log:debug(("resolved mason configuration: %s"):format(server_name))
  -- Log:trace(vim.inspect(conf))

  return conf or {}
end

---Resolve the configuration for a server by merging with the default config
---@param server_name string
---@vararg any config table [optional]
---@return table
local function resolve_config(server_name, ...)
  local defaults = {
    on_attach = require("lvim.lsp").common_on_attach,
    on_init = require("lvim.lsp").common_on_init,
    on_exit = require("lvim.lsp").common_on_exit,
    capabilities = require("lvim.lsp").common_capabilities(),
  }

  local has_custom_provider, custom_config = pcall(require, "modules.lsp.overrides." .. server_name)
  if has_custom_provider then
    Log:trace("Using custom configuration for requested server: " .. server_name)
    defaults = vim.tbl_deep_extend("force", defaults, custom_config)
  else
    Log:trace("Using default configuration for requested server: " .. server_name)
  end

  defaults = vim.tbl_deep_extend("force", defaults, ...)

  return defaults
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
local function buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  require("lspconfig")[server_name].manager.try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
local function client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype

  local active_autocmds = vim.api.nvim_get_autocmds({ event = "FileType", pattern = ft })
  for _, result in pairs(active_autocmds) do
    if result.group_name:match("lspconfig") then
      Log:debug(("[%q] is already configured"):format(server_name))

      return true
    end
  end

  return false
end

local function launch_server(server_name, config)
  local ft = config.filetypes or require("lvim.lsp.utils").get_supported_filetypes(server_name)
  Log:trace(("%s is hooked for fts: %s"):format(server_name, vim.inspect(ft)))

  local callback = function()
    xpcall(function()
      if M.has_setup(server_name) then
        return
      end

      if type(config.override) == "function" then
        config.override(config)

        return
      end

      require("lspconfig")[server_name].setup(config)
    end, debug.traceback)
  end

  callback()

  -- require("utils.setup").define_autocmds({
  --   {
  --     "FileType",
  --     {
  --       group = "lsp_launch_server",
  --       pattern = ft,
  --       callback = function(event)
  --         callback()
  --
  --         pcall(function()
  --           buf_try_add(server_name, event.buf)
  --         end)
  --       end,
  --     },
  --   },
  -- })
end

function M.has_setup(server_name)
  if lvim_lsp_utils.is_client_active(server_name) then
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

  local should_auto_install = function(name)
    local installer_settings = lvim.lsp.installer.setup

    return installer_settings.automatic_installation and not vim.tbl_contains(installer_settings.automatic_installation.exclude, name)
  end

  if not registry.is_installed(pkg_name) then
    if should_auto_install(server_name) then
      Log:debug("Automatic server installation detected")
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
      Log:debug(server_name .. " is not managed by the automatic installer")
    end
  end

  local config = resolve_config(server_name, resolve_mason_config(server_name), user_config)

  launch_server(server_name, config)
end

return M
