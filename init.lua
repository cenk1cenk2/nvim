local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local package_root = vim.fn.stdpath "data" .. "/site/pack"
local compile_path = vim.fn.stdpath "config" .. "/plugin/packer_compiled.lua"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path }
  vim.cmd "packadd packer.nvim"
end

local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

packer.init {
  package_root = package_root,
  compile_path = compile_path,
  git = { clone_timeout = 300 },
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

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
