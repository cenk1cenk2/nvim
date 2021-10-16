local configs = require 'lspconfig/configs'
local servers = require 'nvim-lsp-installer.servers'
local server = require 'nvim-lsp-installer.server'
local installers = require 'nvim-lsp-installer.installers'
local path = require 'nvim-lsp-installer.path'
local platform = require 'nvim-lsp-installer.platform'
local Data = require 'nvim-lsp-installer.data'
local std = require 'nvim-lsp-installer.installers.std'
local context = require 'nvim-lsp-installer.installers.context'

local server_name = 'stylua'

configs[server_name] = {default_config = {}}

local root_dir = server.get_server_root_path(server_name)

local bin_type = Data.coalesce(Data.when(platform.is_mac, 'macos'), Data.when(platform.is_linux, 'linux'), Data.when(platform.is_win, 'win64'))

servers.register(server.Server:new{
  name = server_name,
  root_dir = root_dir,
  installer = installers.pipe({
    context.github_release_file('JohnnyMorganz/StyLua', function(version)
      return ('stylua-%s-%s.zip'):format(version:gsub('^v', ''), bin_type)
    end),
    context.capture(function(ctx)
      return std.unzip_remote(ctx.github_release_file)
    end),
    std.chmod('+x', {'stylua'})
  }),
  default_options = {cmd = {path.concat {root_dir, server_name}}}
})
