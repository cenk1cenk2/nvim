local _, configs = pcall(require, "lspconfig/configs")
local _, servers = pcall(require, "nvim-lsp-installer.servers")
local _, server = pcall(require, "nvim-lsp-installer.server")
local _, path = pcall(require, "nvim-lsp-installer.core.path")
local _, platform = pcall(require, "nvim-lsp-installer.core.platform")
local _, functional = pcall(require, "nvim-lsp-installer.core.functional")
local _, std = pcall(require, "nvim-lsp-installer.core.managers.std")
local _, github = pcall(require, "nvim-lsp-installer.core.managers.github")

local server_name = "rustfmt"

configs[server_name] = { default_config = {} }

local root_dir = server.get_server_root_path(server_name)

servers.register(server.Server:new {
  name = server_name,
  root_dir = root_dir,
  installer = function(ctx)
    local bin_type = functional.coalesce(
      functional.when(platform.is_mac, "macos"),
      functional.when(platform.is_linux, "linux"),
      functional.when(platform.is_win, "windows")
    )

    local source = github.release_file {
      repo = "rust-lang/rustfmt",
      asset_file = function(version)
        return ("rustfmt_%s-x86_64_%s.tar.gz"):format(bin_type, version:gsub("^v", "v"))
      end,
    }

    source.with_receipt()

    std.download_file(source.download_url, source.asset_file)

    std.untar(source.asset_file)

    local out_dir = ("rustfmt_%s-x86_64_%s/"):format(bin_type, source.release:gsub("^v", "v"))

    ctx.fs:rename(("%s/rustfmt"):format(out_dir), "rustfmt")
    ctx.fs:rmrf(out_dir)

    std.chmod("+x", { "rustfmt" })
  end,
  default_options = {
    cmd = { path.concat { root_dir, server_name } },
    cmd_env = {},
  },
})
