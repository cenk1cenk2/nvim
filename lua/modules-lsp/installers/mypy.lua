local M = {}
local helper = require "modules.lsp-installer"

function M.setup()
  local _, configs = pcall(require, "lspconfig/configs")
  local _, servers = pcall(require, "nvim-lsp-installer.servers")
  local _, server = pcall(require, "nvim-lsp-installer.server")

  local _, pip3 = pcall(require, "nvim-lsp-installer.core.managers.pip3")
  local server_name = "mypy"
  local package_name = server_name

  configs[server_name] = { default_config = {} }

  local root_dir = server.get_server_root_path(server_name)

  servers.register(server.Server:new {
    name = server_name,
    root_dir = root_dir,
    async = true,
    installer = pip3.packages { package_name },
    default_options = { cmd = { helper.pip3_executable(root_dir, server_name) }, cmd_env = pip3.env(root_dir) },
  })
end

return M
