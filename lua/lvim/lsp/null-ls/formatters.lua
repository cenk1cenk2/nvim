local M = {}

local null_ls = require "null-ls"
local services = require "lvim.lsp.null-ls.services"
local Log = require "lvim.core.log"

local METHOD = null_ls.methods.FORMATTING

local is_registered = function(name)
  local query = {
    name = name,
    method = METHOD,
  }
  return require("null-ls.sources").is_registered(query)
end

function M.list_registered(filetype)
  local registered_providers = services.list_registered_providers_names(filetype)

  return registered_providers[METHOD] or {}
end

function M.list_supported(filetype)
  local s = require "null-ls.sources"
  local supported_formatters = s.get_supported(filetype, "formatting")
  table.sort(supported_formatters)
  return supported_formatters
end

function M.list_configured(formatter_configs)
  local formatters, errors = {}, {}

  for _, config in pairs(formatter_configs) do
    vim.validate {
      ["config.exe"] = { config.exe, "string" },
    }

    local name = config.exe:gsub("-", "_")
    local formatter = null_ls.builtins.formatting[name]

    if not formatter then
      Log:error("Not a valid formatter: " .. config.exe)
      errors[name] = {} -- Add data here when necessary
    elseif is_registered(config.exe) then
      Log:trace("Skipping registering the source " .. name .. " more than once.")
    else
      local server_available, requested_server = require("nvim-lsp-installer.servers").get_server(name)

      if not server_available then
        Log:warn("Not found formatter: " .. name)
        errors[config.exe] = {} -- Add data here when necessary
      else
        Log:debug("Using formatter: " .. name .. " for " .. vim.inspect(config.filetypes))

        table.insert(
          formatters,
          formatter.with {
            name = name,
            command = table.concat(requested_server._default_options.cmd, " "),
            env = requested_server._default_options.cmd_env,
            filetypes = config.filetypes,
          }
        )
      end
    end
  end

  return { supported = formatters, unsupported = errors }
end

function M.setup(formatter_configs)
  if vim.tbl_isempty(formatter_configs) then
    return
  end

  local formatters = M.list_configured(formatter_configs)

  null_ls.register { sources = formatters.supported }
end

return M
