local M = {}

local log = require("ck.log")

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@return boolean
function M.should_configure(server_name)
  if vim.tbl_contains(nvim.lsp.skipped_servers, server_name) then
    return false
  end

  return true
end

---
---@param force? boolean Always run this.
function M.setup(force)
  if is_headless() and not force then
    log:debug("Headless mode detected, skipping setting lsp support.")

    return
  end

  log:debug("Setting up LSP support")

  log:debug("Installing LSP servers.")

  local ok, _ = pcall(require, "lspconfig")
  if not ok then
    log:warn("lspconfig not available.")

    return
  end

  require("ck.lsp.handlers").setup()

  require("ck.lsp.wrapper").setup()

  xpcall(function()
    require("neoconf").setup({
      jsonls = {
        configured_servers_only = false,
      },
    })

    require("mason-lspconfig").setup({
      -- ensure_installed = nvim.lsp.ensure_installed,
      automatic_installation = {
        exclude = nvim.lsp.skipped_servers,
      },
    })

    require("mason-lspconfig").setup_handlers({
      function(server_name)
        if not M.should_configure(server_name) then
          log:warn(("Skipping configuring LSP: %s"):format(server_name))

          return
        end

        require("ck.lsp.loader").setup(server_name)
      end,
    })

    require("lspconfig.util").on_setup = nil
  end, debug.traceback)

  local ok, installer = pcall(require, "mason-tool-installer")

  if ok then
    installer.setup({
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = nvim.lsp.ensure_installed,

      -- if set to true this will check each tool for updates. If updates
      -- are available the tool will be updated. This setting does not
      -- affect :MasonToolsUpdate or :MasonToolsInstall.
      -- Default: false
      auto_update = false,

      -- automatically install / update on startup. If set to false nothing
      -- will happen on startup. You can use :MasonToolsInstall or
      -- :MasonToolsUpdate to install tools and check for updates.
      -- Default: true
      run_on_start = true,

      start_delay = 1000, -- 3 second delay
    })
  else
    log:warn("LSP installer not available.")
  end

  local registry = require("mason-registry")
  -- Ensure packages are installed and up to date
  registry.refresh(function()
    for _, server_name in pairs(nvim.lsp.ensure_installed) do
      local package_name = require("ck.lsp.loader").to_package_name(server_name)
      local package = registry.get_package(package_name)

      if not registry.is_installed(package_name) then
        log:info("Installing Mason package: %s", package_name)
        package:install()
      else
        package:check_new_version(function(success, result)
          if success then
            local version = result.latest_version

            log:info("Updating Mason package: %s@%s", package_name, version)
            package:install({ version = version })
          end
        end)
      end
    end
  end)

  require("ck.lsp.format").setup()
end

return M
