local M = {}

local null_ls = require "null-ls"
local services = require "lvim.lsp.null-ls.services"
local Log = require "lvim.core.log"

local METHOD = null_ls.methods.CODE_ACTION

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

function M.list_configured(actions_configs)
  local actors, errors = {}, {}

  for _, config in ipairs(actions_configs) do
    vim.validate {
      ["config.exe"] = { config.exe, "string" },
    }

    local name = config.exe:gsub("-", "_")
    local actor = null_ls.builtins.code_actions[name]

    if not actor then
      Log:error("Not a valid code action provider: " .. config.exe)
      errors[config.exe] = {} -- Add data here when necessary
    elseif is_registered(config.exe) then
      Log:trace "Skipping registering the source more than once"
    else
        Log:debug("Using code action provider: " .. name .. " for " .. vim.inspect(config.filetypes))
        table.insert(
          actors,
          actor.with {
            filetypes = config.filetypes,
          }
        )
    end
  end

  return { supported = actors, unsupported = errors }
end

function M.setup(actions_configs)
  if vim.tbl_isempty(actions_configs) then
    return
  end

  local actions = M.list_configured(actions_configs)
  null_ls.register { sources = actions.supported }
end

return M
