local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, npm = pcall(require, "nvim-lsp-installer.core.managers.npm")

local server_name = "markdownlint"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  async = true,
  installer = npm.packages { "markdownlint-cli" },
  default_options = {
    cmd = { server_name },
    cmd_env = {
      npm.env(root_dir),
    },
    extra_args = { "-s", "-c", vim.fn.expand "~/.config/nvim/utils/linter-config/.markdownlintrc.json" },
  },
})
