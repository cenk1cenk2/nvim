local M = {}

M.wrap_to_command = function(arr)
  for _, v in pairs(arr) do vim.api.nvim_command('command!' .. ' ' .. v[1] .. ' ' .. v[2]) end
end

M.set_option = function(arr)
  for k, v in pairs(arr) do vim.api.nvim_exec('set' .. ' ' .. k .. '=' .. v, true) end
end

return M
