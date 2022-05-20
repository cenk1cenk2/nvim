local M = {}
local helper = require "modules.lsp-installer"

function M.setup()
  local _, configs = pcall(require, "lspconfig/configs")
  local _, servers = pcall(require, "nvim-lsp-installer.servers")
  local _, server = pcall(require, "nvim-lsp-installer.server")
  local _, path = pcall(require, "nvim-lsp-installer.core.path")
  local _, platform = pcall(require, "nvim-lsp-installer.core.platform")
  local _, functional = pcall(require, "nvim-lsp-installer.core.functional")
  local _, std = pcall(require, "nvim-lsp-installer.core.managers.std")
  local _, github = pcall(require, "nvim-lsp-installer.core.managers.github")

  local server_name = "hadolint"

  configs[server_name] = { default_config = {} }

  local root_dir = server.get_server_root_path(server_name)

  servers.register(server.Server:new {
    name = server_name,
    root_dir = root_dir,
    installer = function()
      local bin_type = functional.coalesce(
        functional.when(platform.is_mac, "Darwin"),
        functional.when(platform.is_linux, "Linux")
      )

      local asset = ("hadolint-%s-x86_64"):format(bin_type)

      local source = github.release_file {
        repo = "hadolint/hadolint",
        asset_file = asset,
      }

      source.with_receipt()

      std.download_file(source.download_url, server_name)

      std.chmod("+x", { server_name })
    end,
    default_options = {
      cmd = { helper.executable(root_dir, server_name) },
      cmd_env = {},
    },
  })
end

return M
