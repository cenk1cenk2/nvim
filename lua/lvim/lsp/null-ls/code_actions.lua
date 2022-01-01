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
      local actor_cmd
      if config.managed then
        local server_available, requested_server = require("nvim-lsp-installer.servers").get_server(name)

        if not server_available then
          Log:warn("Not found managed code action provider: " .. name)
          errors[config.exe] = {} -- Add data here when necessary
        else
          actor_cmd = services.find_command(table.concat(requested_server._default_options.cmd, " "))
          -- TODO: add environment variable parsing here.
        end
      else
        actor_cmd = services.find_command(actor._opts.command)
      end

      if not actor_cmd then
        Log:warn("Not found: " .. actor._opts.command)
        errors[name] = {} -- Add data here when necessary
      else
        Log:debug("Using code action provider: " .. actor_cmd .. " for " .. vim.inspect(config.filetypes))
        table.insert(
          actors,
          actor.with {
            name = name,
            command = actor_cmd,
            extra_args = config.args,
            filetypes = config.filetypes,
          }
        )
      end
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
