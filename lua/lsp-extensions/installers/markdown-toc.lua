local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, installers = pcall(require, "nvim-lsp-installer.installers")
local _, npm = pcall(require, "nvim-lsp-installer.installers.npm")

local server_name = "markdown_toc"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe { npm.packages { "markdown-toc" } },
  default_options = { cmd = { "markdown-toc" }, cmd_env = npm.env(root_dir) },
})
