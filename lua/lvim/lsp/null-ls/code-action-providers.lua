local M = {}

local null_ls = require "null-ls"
local services = require "lvim.lsp.null-ls.services"
local Log = require "lvim.core.log"

local is_registered = function(name)
  local query = {
    name = name,
    method = null_ls.methods.CODE_ACTION,
  }
  return require("null-ls.sources").is_registered(query)
end

function M.list_registered_providers(filetype)
  local code_action_provider_method = null_ls.methods.CODE_ACTION
  local registered_providers = services.list_registered_providers_names(filetype)
  return registered_providers[code_action_provider_method] or {}
end

function M.list_available(filetype)
  local code_action_providers = {}
  local tbl = require "lvim.utils.table"
  for _, provider in pairs(null_ls.builtins.diagnostics) do
    if tbl.contains(provider.filetypes or {}, function(ft)
      return ft == "*" or ft == filetype
    end) then
      table.insert(code_action_providers, provider.name)
    end
  end

  table.sort(code_action_providers)
  return code_action_providers
end

function M.list_configured(code_action_provider_configs)
  local code_action_providers, errors = {}, {}

  for _, ca_config in pairs(code_action_provider_configs) do
    local name = ca_config.exe:gsub("-", "_")
    local code_action_provider = null_ls.builtins.code_actions[name]

    if not code_action_provider then
      Log:error("Not a valid code action provider: " .. ca_config.exe)
      errors[ca_config.exe] = {} -- Add data here when necessary
    elseif is_registered(ca_config.exe) then
      Log:trace "Skipping registering the source more than once"
    else
      local code_action_provider_cmd
      if ca_config.managed then
        local server_available, requested_server = require("nvim-lsp-installer.servers").get_server(name)

        if not server_available then
          Log:warn("Not found managed code action provider: " .. name)
          errors[ca_config.exe] = {} -- Add data here when necessary
        else
          code_action_provider_cmd = services.find_command(table.concat(requested_server._default_options.cmd, " "))
        end
      else
        code_action_provider_cmd = services.find_command(code_action_provider._opts.command)
      end

      if not code_action_provider_cmd then
        Log:warn("Not found: " .. code_action_provider._opts.command)
        errors[name] = {} -- Add data here when necessary
      else
        require("lvim.lsp.null-ls.services").join_environment_to_command(ca_config.environment)

        Log:debug(
          "Using code action provider: " .. code_action_provider_cmd .. " for " .. vim.inspect(ca_config.filetypes)
        )
        table.insert(
          code_action_providers,
          code_action_provider.with {
            command = code_action_provider_cmd,
            extra_args = ca_config.args,
            filetypes = ca_config.filetypes,
          }
        )
      end
    end
  end

  return { supported = code_action_providers, unsupported = errors }
end

function M.setup(code_action_provider_configs)
  if vim.tbl_isempty(code_action_provider_configs) then
    return
  end

  local code_action_providers = M.list_configured(code_action_provider_configs)
  null_ls.register { sources = code_action_providers.supported }
end

return M
