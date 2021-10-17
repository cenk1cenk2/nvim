local configs = require "lspconfig/configs"
local servers = require "nvim-lsp-installer.servers"
local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local pip3 = require "nvim-lsp-installer.installers.pip3"

local server_name = "mypy"
local package_name = server_name

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe {
    pip3.packages { package_name },
  },
  default_options = { cmd = { pip3.executable(root_dir, package_name) } },
})
