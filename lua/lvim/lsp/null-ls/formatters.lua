local M = {}

local null_ls = require "null-ls"
local services = require "lvim.lsp.null-ls.services"
local Log = require "lvim.core.log"

local is_registered = function(name)
  local query = {
    name = name,
    method = null_ls.methods.FORMATTING,
  }
  return require("null-ls.sources").is_registered(query)
end

function M.list_registered(filetype)
  local formatter_method = null_ls.methods.FORMATTING
  local registered_providers = services.list_registered_providers_names(filetype)
  return registered_providers[formatter_method] or {}
end

function M.list_supported(filetype)
  local s = require "null-ls.sources"
  local supported_formatters = s.get_supported(filetype, "formatting")
  table.sort(supported_formatters)
  return supported_formatters
end

function M.list_configured(formatter_configs)
  local formatters, errors = {}, {}

  for _, fmt_config in ipairs(formatter_configs) do
    local name = fmt_config.exe:gsub("-", "_")
    local formatter = null_ls.builtins.formatting[name]

    if not formatter then
      Log:error("Not a valid formatter: " .. fmt_config.exe)
      errors[name] = {} -- Add data here when necessary
    elseif is_registered(fmt_config.exe) then
      Log:trace "Skipping registering  the source more than once"
      else

        Log:debug("Using formatter: " .. name .. " for " .. vim.inspect(fmt_config.filetypes))
        table.insert(
          formatters,
          formatter.with {
            filetypes = fmt_config.filetypes,
          }
        )
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
