local M = {}

local log = require("core.log")
local setup = require("setup")

local function add_lsp_buffer_options(bufnr)
  for k, v in pairs(nvim.lsp.buffer_options) do
    vim.api.nvim_set_option_value(k, v, { buf = bufnr })
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  setup.load_keymaps(nvim.lsp.buffer_mappings, { buffer = bufnr })
end

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

function M.common_on_exit(client, bufnr)
  if #nvim.lsp.on_exit_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_exit) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_exit")
  end
end

function M.common_on_init(client, bufnr)
  if #nvim.lsp.on_init_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_init_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_init_callbacks")
  end
end

function M.common_on_attach(client, bufnr)
  if #nvim.lsp.on_attach_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_attach_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_attach_callbacks")
  end

  local lu = require("core.lsp.utils")

  if nvim.lsp.code_lens.refresh then
    lu.setup_codelens_refresh(client, bufnr)
  end

  if nvim.lsp.inlay_hints.enabled then
    lu.setup_inlay_hints(client, bufnr)
  end

  add_lsp_buffer_keybindings(bufnr)
  add_lsp_buffer_options(bufnr)
end

function M.get_common_opts()
  return {
    on_attach = M.common_on_attach,
    on_init = M.common_on_init,
    on_exit = M.common_on_exit,
    capabilities = M.common_capabilities(),
  }
end

function M.setup(force)
  if is_headless() and not force then
    log:debug("headless mode detected, skipping setting lsp support")
    return
  end

  log:debug("Setting up LSP support")

  log:debug("Installing LSP servers.")

  local installer_ok, installer = pcall(require, "mason-tool-installer")

  if installer_ok then
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

  local lsp_status_ok, _ = pcall(require, "lspconfig")
  if not lsp_status_ok then
    return
  end

  require("modules.lsp").setup()

  require("core.lsp.handlers").setup()

  xpcall(function()
    require("neoconf").setup({
      jsonls = {
        configured_servers_only = false,
      },
    })
    require("mason-lspconfig").setup(nvim.lsp.installer.setup)
    require("mason-lspconfig").setup_handlers({
      function(server_name)
        if not require("core.lsp.attach").should_configure(server_name) then
          log:debug(("Skipping configuring LSP: %s"):format(server_name))

          return
        end

        require("core.lsp.manager").setup(server_name)
      end,
    })

    local util = require("lspconfig.util")
    util.on_setup = nil
  end, debug.traceback)

  require("core.lsp.format").setup()
end

return M
