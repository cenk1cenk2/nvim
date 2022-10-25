vim.cmd [[
  autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
  autocmd FileType gitcommit setlocal wrap
]]
