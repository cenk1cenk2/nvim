vim.cmd [[
 au BufRead,BufNewFile *.tf setlocal filetype=terraform
 au BufRead,BufNewFile *.tfvars setlocal filetype=terraform
]]
