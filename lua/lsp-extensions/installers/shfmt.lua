local configs = require "lspconfig/configs"
local servers = require "nvim-lsp-installer.servers"
local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local path = require "nvim-lsp-installer.path"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"

local server_name = "shfmt"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

local bin_type = Data.coalesce(
  Data.when(platform.is_mac, "macos"),
  Data.when(platform.is_linux, "linux"),
  Data.when(platform.is_win, "win64")
)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe {
    context.use_github_release_file("mvdan/sh", function(version)
      return ("shfmt_%s_%s_amd64"):format(version:gsub("^v", "v"), bin_type)
    end),
    context.capture(function(ctx)
      return std.download_file(ctx.github_release_file, "shfmt")
    end),
    std.chmod("+x", { "shfmt" }),
  },
  default_options = { cmd = { path.concat { root_dir, server_name } } },
})