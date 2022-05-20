local M = {}
local helper = require "modules.lsp-installer"

function M.setup()
  local _, configs = pcall(require, "lspconfig/configs")
  local _, servers = pcall(require, "nvim-lsp-installer.servers")
  local _, server = pcall(require, "nvim-lsp-installer.server")
  local _, npm = pcall(require, "nvim-lsp-installer.core.managers.npm")

  local server_name = "rustywind"

  configs[server_name] = { default_config = {} }

  local root_dir = server.get_server_root_path(server_name)

  servers.register(server.Server:new {
    name = server_name,
    root_dir = root_dir,
    async = true,
    installer = npm.packages { server_name },
    default_options = { cmd = { helper.npm_executable(root_dir, server_name) }, cmd_env = npm.env(root_dir) },
  })
end

return M
