local M = {}

function M.find_command(command)
  if vim.fn.executable(command) == 1 then
    return command
  end
  return nil
end

function M.list_registered_providers_names(filetype)
  local u = require "null-ls.utils"
  local c = require "null-ls.config"
  local registered = {}
  for method, source in pairs(c.get()._methods) do
    for name, filetypes in pairs(source) do
      if u.filetype_matches(filetypes, filetype) then
        registered[method] = registered[method] or {}
        table.insert(registered[method], name)
      end
    end
  end

  return registered
end

function M.join_environment_to_command(environment)
  if environment and not vim.tbl_isempty(environment) then
    for key, value in pairs(environment) do
      local command = key .. "=" .. value
      vim.api.nvim_exec("let", "$" .. command)
    end
  end
end

return M
