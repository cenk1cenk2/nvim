local M = {}
local helper = require "modules.lsp-installer"

function M.setup()
  local _, configs = pcall(require, "lspconfig/configs")
  local _, servers = pcall(require, "nvim-lsp-installer.servers")
  local _, server = pcall(require, "nvim-lsp-installer.server")
  local _, npm = pcall(require, "nvim-lsp-installer.core.managers.npm")
  local _, path = pcall(require, "nvim-lsp-installer.core.path")

  local server_name = "prettierd"

  configs[server_name] = { default_config = {} }

  local root_dir = server.get_server_root_path(server_name)

  servers.register(server.Server:new {
    name = server_name,
    root_dir = root_dir,
    async = true,
    installer = npm.packages { "@fsouza/prettierd" },
    default_options = {
      cmd = { helper.npm_executable(root_dir, server_name) },
      dynamic_command = false,
      cmd_env = vim.tbl_extend("force", npm.env(root_dir), {
        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand "~/.config/nvim/utils/linter-config/.prettierrc.json",
      }),
    },
  })
end

return M
