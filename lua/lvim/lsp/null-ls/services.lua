local M = {}

function M.find_command(command)
  if vim.fn.executable(command) == 1 then
    return command
  end

  return nil
end

function M.list_registered_providers_names(filetype)
  local s = require "null-ls.sources"
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

function M.append_environment_vars_to_command(command, environment)
  if not environment or vim.tbl_isempty(environment) then
    return command
  end

  for key, value in pairs(environment) do
    command = key .. "=" .. value .. " " .. command
  end

  return command
end

return M
