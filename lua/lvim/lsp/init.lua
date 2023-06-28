local M = {}

local Log = require("lvim.core.log")
local autocmds = require("lvim.core.autocmds")
local keymappings = require("lvim.keymappings")

local function add_lsp_buffer_options(bufnr)
  for k, v in pairs(lvim.lsp.buffer_options) do
    vim.api.nvim_buf_set_option(bufnr, k, v)
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  keymappings.load(lvim.lsp.buffer_mappings, { buffer = bufnr, noremap = true, silent = true })
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
  if #lvim.lsp.on_exit > 0 then
    for _, cb in pairs(lvim.lsp.on_exit) do
      cb(client, bufnr)
    end
    Log:trace("Called lsp.on_exit")
  end

  if lvim.lsp.code_lens_refresh then
    autocmds.clear_augroup("lsp_code_lens_refresh")
  end
end

function M.common_on_init(client, bufnr)
  if #lvim.lsp.on_init_callbacks > 0 then
    for _, cb in pairs(lvim.lsp.on_init_callbacks) do
      cb(client, bufnr)
    end
    Log:trace("Called lsp.on_init_callbacks")
  end
end

function M.common_on_attach(client, bufnr)
  if #lvim.lsp.on_attach_callbacks > 0 then
    for _, cb in pairs(lvim.lsp.on_attach_callbacks) do
      cb(client, bufnr)
    end
    Log:trace("Called lsp.on_attach_callbacks")
  end

  local lu = require("lvim.lsp.utils")
  if lvim.lsp.code_lens_refresh then
    lu.setup_codelens_refresh(client, bufnr)
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
    Log:debug("headless mode detected, skipping setting lsp support")
    return
  end

  Log:debug("Setting up LSP support")

  Log:debug("Installing LSP servers.")

  local installer_ok, installer = pcall(require, "mason-tool-installer")

  if installer_ok then
    installer.setup({
      -- a list of all tools you want to ensure are installed upon
      -- start; they should be the names Mason uses for each tool
      ensure_installed = lvim.lsp.ensure_installed,

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
    Log:warn("LSP installer not available.")
  end

  local lsp_status_ok, _ = pcall(require, "lspconfig")
  if not lsp_status_ok then
    return
  end

  require("modules.lsp").setup()

  for _, sign in ipairs(lvim.lsp.diagnostics.signs.values) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  require("lvim.lsp.handlers").setup()

  pcall(function()
    require("nlspsettings").setup(lvim.lsp.nlsp_settings.setup)
  end)

  xpcall(function()
    require("mason-lspconfig").setup(lvim.lsp.installer.setup)
    require("mason-lspconfig").setup_handlers({
      function(server_name)
        if not require("lvim.lsp.attach").should_configure(server_name) then
          Log:debug(("Skipping configuring LSP: %s"):format(server_name))

          return
        end

        require("lvim.lsp.manager").setup(server_name)
      end,
    })

    local util = require("lspconfig.util")
    util.on_setup = nil
  end, debug.traceback)

  require("lvim.lsp.null-ls").setup()

  autocmds.configure_format_on_save()
end

return M
