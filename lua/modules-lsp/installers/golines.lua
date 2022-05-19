local M = {}

function M.setup()
  local _, configs = pcall(require, "lspconfig/configs")
  local _, servers = pcall(require, "nvim-lsp-installer.servers")
  local _, server = pcall(require, "nvim-lsp-installer.server")
  local _, go = pcall(require, "nvim-lsp-installer.core.managers.go")

  local server_name = "golines"

  configs[server_name] = { default_config = {} }

  local root_dir = server.get_server_root_path(server_name)

  servers.register(server.Server:new {
    name = server_name,
    root_dir = root_dir,
    installer = go.packages { "github.com/segmentio/golines" },
    default_options = { cmd = { server_name }, cmd_env = go.env(root_dir) },
  })
end

return M
