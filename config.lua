lvim.log.level = 'debug'

local server_available, requested_server = require('nvim-lsp-installer.servers').get_server('stylua')


lvim.lang.lua.formatters = {{filetypes = {'lua'}, exe = 'lua-format', args = {'-i', '-c', '/home/cenk/.config/nvim-old/utils/linter-config/luaformat.yml'}}}

lvim.lsp.ensure_installed = {'tsserver', 'eslint_d', 'stylua'}
