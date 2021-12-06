-- local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
-- local package_root = vim.fn.stdpath "data" .. "/site/pack"
-- local compile_path = vim.fn.stdpath "config" .. "/plugin/packer_compiled.lua"

local init_path = debug.getinfo(1).source:sub(2)
local base_dir = init_path:match("(.*[/\\])"):sub(1, -2)

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

-- if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
--   vim.fn.system { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path }
--   vim.cmd "packadd packer.nvim"
-- end
--
-- local packer_ok, packer = pcall(require, "packer")
-- if not packer_ok then
--   return
-- end
--
-- packer.init {
--   package_root = package_root,
--   compile_path = compile_path,
--   git = { clone_timeout = 300 },
--   display = {
--     open_fn = function()
--       return require("packer.util").float { border = "rounded" }
--     end,
--   },
-- }

require("lvim.bootstrap"):init(base_dir)

require("lvim.config"):load()

local plugins = require "lvim.plugins"
require("lvim.plugin-loader").load { plugins, lvim.plugins }

local Log = require "lvim.core.log"
Log:debug "neovim"

local commands = require "lvim.core.commands"
commands.load(commands.defaults)

require("lvim.lsp").setup()
