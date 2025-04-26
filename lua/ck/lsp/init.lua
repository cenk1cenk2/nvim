local M = {}

local log = require("ck.log")

local function to_package_name(server_name)
  return require("mason-lspconfig.mappings.server").lspconfig_to_package[server_name] or server_name
end

---
---@param force? boolean Always run this.
function M.setup(force)
  if is_headless() and not force then
    log:debug("Headless mode detected, skipping setting lsp support.")

    return
  end

  log:debug("Setting up LSP support")

  require("neoconf").setup({
    jsonls = {
      configured_servers_only = false,
    },
  })

  require("lspconfig")

  require("ck.lsp.handlers").setup()
  require("ck.lsp.loader").setup()

  log:debug("Installing LSP servers.")

  local ok, installer = pcall(require, "mason-tool-installer")

  if ok then
    installer.setup({
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = nvim.lsp.packages,

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

      start_delay = 1000, -- 3 second delay,

      integrations = {
        ["mason-lspconfig"] = true,
        ["mason-null-ls"] = false,
        ["mason-nvim-dap"] = true,
      },
    })
  else
    log:error("LSP installer not available.")
  end

  if not is_headless() then
    local registry = require("mason-registry")

    -- Ensure packages are installed and up to date
    registry.refresh(function()
      for _, server_name in pairs(nvim.lsp.packages) do
        local package_name = to_package_name(server_name)
        local package = registry.get_package(package_name)

        if not registry.is_installed(package_name) then
          log:info("Installing Mason package: %s", package_name)
          package:install()
        elseif nvim.lsp.automatic_update then
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
  else
    log:debug("Skipping automatic LSP installation on headless mode.")
  end

  require("ck.keys.lsp").setup()
  require("ck.lsp.commands").setup()
  require("ck.lsp.format").setup()
end

return M
