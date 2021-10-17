require("lvim.bootstrap"):init()

require("lvim.config"):load()

local plugins = require "lvim.plugins"
require("lvim.plugin-loader"):load { plugins, lvim.plugins }

local Log = require "lvim.core.log"
Log:debug "neovim"

vim.g.colors_name = lvim.colorscheme
vim.cmd("colorscheme " .. lvim.colorscheme)

local commands = require "lvim.core.commands"
commands.load(commands.defaults)

require("lvim.keymappings").setup()

require("lvim.lsp").setup()
