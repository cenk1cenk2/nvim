vim.cmd [[
 au BufRead,BufNewFile deploy.yml setlocal filetype=yaml.ansible
 au BufRead,BufNewFile provision.yml setlocal filetype=yaml.ansible
]]
