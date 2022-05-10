local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, installers = pcall(require, "nvim-lsp-installer.installers")
local _, pip3 = pcall(require, "nvim-lsp-installer.installers.pip3")
local helpers = require "lsp-extensions.lsp-installer-helpers"

local server_name = "djlint"
local package_name = server_name

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe {
    pip3.packages { package_name },
  },
  default_options = { cmd = { helpers.pip3_executable(root_dir, package_name) }, cmd_env = {} },
})
