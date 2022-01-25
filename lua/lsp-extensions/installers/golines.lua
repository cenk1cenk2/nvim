local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, installers = pcall(require, "nvim-lsp-installer.installers")
local _, go = pcall(require, "nvim-lsp-installer.installers.go")
local helpers = require "lsp-extensions.lsp-installer-helpers"

local server_name = "golines"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe { go.packages { "github.com/segmentio/golines" } },
  default_options = { cmd = { helpers.go_executable(root_dir, server_name) }, cmd_env = {} },
})
