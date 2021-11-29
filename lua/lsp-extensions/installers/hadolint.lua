local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, installers = pcall(require, "nvim-lsp-installer.installers")
local _, path = pcall(require, "nvim-lsp-installer.path")
local _, platform = pcall(require, "nvim-lsp-installer.platform")
local _, Data = pcall(require, "nvim-lsp-installer.data")
local _, std = pcall(require, "nvim-lsp-installer.installers.std")
local _, context = pcall(require, "nvim-lsp-installer.installers.context")

local server_name = "hadolint"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

local bin_type = Data.coalesce(Data.when(platform.is_mac, "Darwin"), Data.when(platform.is_linux, "Linux"))

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe {
    context.use_github_release_file("hadolint/hadolint", function()
      return ("hadolint-%s-x86_64"):format(bin_type)
    end),
    context.capture(function(ctx)
      return std.download_file(ctx.github_release_file, "hadolint")
    end),
    std.chmod("+x", { "hadolint" }),
  },
  default_options = { cmd = { path.concat { root_dir, server_name } } },
})
