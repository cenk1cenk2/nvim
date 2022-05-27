vim.cmd [[
 au BufRead,BufNewFile *.j2 set filetype=jinja
 au FileType jinja,jinja2 set setlocal indentexpr=nvim_treesitter#indent()
]]
