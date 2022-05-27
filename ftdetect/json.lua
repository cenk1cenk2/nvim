vim.cmd [[
 au BufRead,BufNewFile tsconfig.json setlocal filetype=jsonc
 au BufRead,BufNewFile .prettierrc setlocal filetype=json
 au BufRead,BufNewFile .eslintrc setlocal filetype=json
 au BufRead,BufNewFile .babelrc setlocal filetype=json
]]
