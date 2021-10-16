local M = {}

M.GDiffCompare = function()
  vim.call('inputsave')

  local branch = vim.fn.input('Compare file with branch' .. ' ➜ ')

  vim.api.nvim_command('normal :esc<CR>')

  local current = vim.api.nvim_buf_get_name(0)
  vim.api.nvim_out_write('Comparing with branch: ' .. current .. ' ➜ ' .. branch .. '\n')

  vim.api.nvim_command(':Gvdiffsplit ' .. branch .. ':%')

  vim.call('inputrestore')
end

M.setup = function()
  require('utils.command').wrap_to_command({{'GDiffCompare', 'lua require("modules.fugitive-compare-branch").GDiffCompare()'}})
end

return M