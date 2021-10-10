local M = {}

function M.setup()
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') then vim.cmd('syntax reset') end
  vim.o.background = 'dark'
  vim.o.termguicolors = true
  vim.g.colors_name = 'onedarker'
  vim.api.nvim_command([[syntax on]])
  vim.api.nvim_command([[set termguicolors]])
  vim.api.nvim_command([[colorscheme onedarker]])
  require('onedarker.highlights').setup()
  require('onedarker.terminal').setup()
end

return M
