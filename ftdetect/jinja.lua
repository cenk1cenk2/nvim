vim.cmd [[
 au BufRead,BufNewFile *.j2 setlocal filetype=jinja
 au FileType jinja,jinja2 setlocal setlocal indentexpr=nvim_treesitter#indent()
]]
