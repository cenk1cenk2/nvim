local configs = require "lspconfig/configs"
local servers = require "nvim-lsp-installer.servers"
local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local npm = require "nvim-lsp-installer.installers.npm"

local server_name = "rustywind"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe { npm.packages { "rustywind" } },
  default_options = { cmd = { npm.executable(root_dir, server_name) } },
})
