local M = {}

local null_ls = require "null-ls"
local services = require "lvim.lsp.null-ls.services"
local Log = require "lvim.core.log"

local METHOD = null_ls.methods.DIAGNOSTICS

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
  local supported_linters = s.get_supported(filetype, "diagnostics")
  table.sort(supported_linters)
  return supported_linters
end

function M.list_configured(linter_configs)
  local linters, errors = {}, {}

  for _, config in pairs(linter_configs) do
    vim.validate {
      ["config.exe"] = { config.exe, "string" },
    }

    local name = config.exe:gsub("-", "_")
    local linter = null_ls.builtins.diagnostics[name]

    if not linter then
      Log:error("Not a valid linter: " .. config.exe)
      errors[name] = {} -- Add data here when necessary
    elseif is_registered(config.exe) then
      Log:trace("Skipping registering the source " .. name .. " more than once.")
    else
      local server_available, requested_server = require("nvim-lsp-installer.servers").get_server(name)

      if not server_available then
        Log:warn("Not found linter: " .. name)
        errors[config.exe] = {} -- Add data here when necessary
      else
        Log:debug("Using linter: " .. name .. " for " .. vim.inspect(config.filetypes))

        table.insert(
          linters,
          linter.with {
            name = name,
            command = table.concat(requested_server._default_options.cmd, " "),
            env = requested_server._default_options.cmd_env or {},
            filetypes = config.filetypes,
          }
        )
      end
    end
  end

  return { supported = linters, unsupported = errors }
end

function M.setup(linter_configs)
  if vim.tbl_isempty(linter_configs) then
    return
  end

  local linters = M.list_configured(linter_configs)
  null_ls.register { sources = linters.supported }
end

return M
