vim.cmd [[
 au BufRead,BufNewFile *.rgignore setlocal filetype=gitignore
 au BufRead,BufNewFile *.npmignore setlocal filetype=gitignore
 au BufRead,BufNewFile *.prettierignore setlocal filetype=gitignore
 au BufRead,BufNewFile *.eslintignore setlocal filetype=gitignore
]]
