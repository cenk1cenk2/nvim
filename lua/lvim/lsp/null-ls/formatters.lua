local M = {}

local null_ls = require "null-ls"
local services = require "lvim.lsp.null-ls.services"
local Log = require "lvim.core.log"

function M.list_supported_names(filetype)
  local null_ls_methods = null_ls.methods
  local formatter_method = null_ls_methods.internal["FORMATTING"]
  local registered_providers = services.list_registered_providers_names(filetype)
  return registered_providers[formatter_method] or {}
end

function M.list_available(filetype)
  local formatters = {}
  local tbl = require "lvim.utils.table"
  for _, provider in pairs(null_ls.builtins.formatting) do
    if tbl.contains(provider.filetypes or {}, function(ft)
      return ft == "*" or ft == filetype
    end) then
      table.insert(formatters, provider.name)
    end
  end

  return formatters
end

function M.list_configured(formatter_configs)
  local formatters, errors = {}, {}

  for _, fmt_config in ipairs(formatter_configs) do
    local formatter_name = fmt_config.exe:gsub("-", "_")
    local formatter = null_ls.builtins.formatting[formatter_name]

    if not formatter then
      Log:error("Not a valid formatter: " .. fmt_config.exe)
      errors[fmt_config.exe] = {} -- Add data here when necessary
    else
      local formatter_cmd
      if fmt_config.managed then
        local server_available, requested_server = require("nvim-lsp-installer.servers").get_server(formatter_name)

        if not server_available then
          Log:warn("Not found managed formatter: " .. formatter_name)
          errors[fmt_config.exe] = {} -- Add data here when necessary
        else
          formatter_cmd = services.find_command(table.concat(requested_server._default_options.cmd, " "))
        end
      else
        formatter_cmd = services.find_command(formatter._opts.command)
      end

      if not formatter_cmd then
        Log:warn("Not found: " .. formatter._opts.command)
        errors[fmt_config.exe] = {} -- Add data here when necessary
      else
        Log:debug("Using formatter: " .. formatter_cmd)
        formatters[fmt_config.exe] = formatter.with {
          command = formatter_cmd,
          extra_args = fmt_config.args,
          filetypes = fmt_config.filetypes,
        }
      end
    end
  end

  return { supported = formatters, unsupported = errors }
end

function M.setup(formatter_configs)
  if vim.tbl_isempty(formatter_configs) then
    return
  end

  local formatters_by_ft = M.list_configured(formatter_configs)
  null_ls.register { sources = formatters_by_ft.supported }
end

return M
