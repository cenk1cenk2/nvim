local M = {}

function M.setup()
  local _, configs = pcall(require, "lspconfig/configs")
  local _, servers = pcall(require, "nvim-lsp-installer.servers")
  local _, server = pcall(require, "nvim-lsp-installer.server")
  local _, path = pcall(require, "nvim-lsp-installer.core.path")
  local _, platform = pcall(require, "nvim-lsp-installer.core.platform")
  local _, functional = pcall(require, "nvim-lsp-installer.core.functional")
  local _, std = pcall(require, "nvim-lsp-installer.core.managers.std")
  local _, github = pcall(require, "nvim-lsp-installer.core.managers.github")

  local server_name = "misspell"

  configs[server_name] = { default_config = {} }

  local root_dir = server.get_server_root_path(server_name)

  servers.register(server.Server:new {
    name = server_name,
    root_dir = root_dir,
    installer = function()
      local bin_type = functional.coalesce(
        functional.when(platform.is_mac, "macos"),
        functional.when(platform.is_linux, "linux"),
        functional.when(platform.is_win, "win64")
      )

      local source = github.release_file {
        repo = "client9/misspell",
        asset_file = function(version)
          return ("misspell_%s_%s_64bit.tar.gz"):format(version:gsub("^v", ""), bin_type)
        end,
      }

      source.with_receipt()

      std.download_file(source.download_url, source.asset_file)

      std.untar(source.asset_file)

      std.chmod("+x", { "misspell" })
    end,
    default_options = {
      cmd = { path.concat { root_dir, server_name } },
      cmd_env = {},
    },
  })
end

return M