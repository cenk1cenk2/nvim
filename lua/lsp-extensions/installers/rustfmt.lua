local configs = require "lspconfig/configs"
local servers = require "nvim-lsp-installer.servers"
local server = require "nvim-lsp-installer.server"
local installers = require "nvim-lsp-installer.installers"
local path = require "nvim-lsp-installer.path"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"

local server_name = "rustfmt"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

local bin_type = Data.coalesce(
  Data.when(platform.is_mac, "macos"),
  Data.when(platform.is_linux, "linux"),
  Data.when(platform.is_win, "windows")
)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe {
    context.use_github_release_file("rust-lang/rustfmt", function(version)
      return ("rustfmt_%s-x86_64_%s.tar.gz"):format(bin_type, version:gsub("^v", "v"))
    end),
    context.capture(function(ctx)
      return std.untargz_remote(ctx.github_release_file)
    end),
    context.capture(function(ctx)
      return std.rename(
        ("rustfmt_%s-x86_64_%s"):format(bin_type, ctx.requested_server_version:gsub("^v", "v")),
        "server"
      )
    end),
  },
  default_options = { cmd = { path.concat { root_dir, "server", server_name } } },
})
