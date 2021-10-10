require('bootstrap'):init()

local config = require('config')
-- config:init()
config:load()

local plugins = require 'plugins'
require('plugin-loader'):load{plugins, lvim.plugins}

local Log = require 'core.log'
Log:debug 'Starting LunarVim'

vim.g.colors_name = lvim.colorscheme -- Colorscheme must get called after plugins are loaded or it will break new installs.
vim.cmd('colorscheme ' .. lvim.colorscheme)

local commands = require 'core.commands'
commands.load(commands.defaults)

require('keymappings').setup()

require('lsp').setup()
