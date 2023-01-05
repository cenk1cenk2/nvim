local M = {}

local Log = require("lvim.core.log")

function M.find_command(command)
  return command
end

function M.list_registered_providers_names(filetype)
  local s = require("null-ls.sources")
  local available_sources = s.get_available(filetype)
  local registered = {}

  for _, source in ipairs(available_sources) do
    for method in pairs(source.methods) do
      registered[method] = registered[method] or {}
      table.insert(registered[method], source.name)
    end
  end

  return registered
end

function M.register_sources(configs, method)
  local null_ls = require("null-ls")
  local is_registered = require("null-ls.sources").is_registered

  local sources, registered_names = {}, {}

  for _, config in ipairs(configs) do
    local command = config.command
    local name = config.name or command:gsub("-", "_")
    local type = method == null_ls.methods.CODE_ACTION and "code_actions" or null_ls.methods[method]:lower()
    local source = type and null_ls.builtins[type][name]
    Log:trace(("Received request to register [%s] as a %s source"):format(name, type))
    if not source then
      Log:error("Not a valid source: " .. name)

      return registered_names
    elseif is_registered({ name = source.name or name, method = method }) then
      Log:trace(("Skipping registering [%s] more than once"):format(name))

      return registered_names
    end

    local opts = vim.tbl_extend("force", vim.deepcopy(config), {
      name = name,
      command = command,
      disabled_filetypes = vim.list_extend(lvim.disabled_filetypes, config.disabled_filetypes or {}),
    })

    Log:debug(("Registering source for method %s: %s"):format(method, name))
    Log:trace(vim.inspect(opts))

    local s = source.with(opts)

    if opts.dynamic_command == false then
      s._opts.dynamic_command = nil
    end

    table.insert(sources, s)

    vim.list_extend(registered_names, { name })
  end

  if #sources > 0 then
    null_ls.register({ sources = sources })
  end

  return registered_names
end

return M
