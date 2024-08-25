local M = {}

local log = require("ck.log")
local setup = require("ck.setup")

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

  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

---@alias LspOnCallback fun(client: vim.lsp.Client, bufnr: number)

---@type LspOnCallback
function M.common_on_exit(client, bufnr)
  if #nvim.lsp.on_exit_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_exit) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_exit")
  end
end

---@type LspOnCallback
function M.common_on_init(client, bufnr)
  if #nvim.lsp.on_init_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_init_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_init_callbacks")
  end
end

---@type LspOnCallback
function M.common_on_attach(client, bufnr)
  if #nvim.lsp.on_attach_callbacks > 0 then
    for _, cb in pairs(nvim.lsp.on_attach_callbacks) do
      cb(client, bufnr)
    end
    log:trace("Called lsp.on_attach_callbacks")
  end

  if nvim.lsp.code_lens.refresh then
    local method = "textDocument/codeLens"
    local ok, codelens_supported = pcall(function()
      return client.supports_method(method)
    end)

    if not ok or not codelens_supported then
      return
    end

    local group = "lsp_code_lens_refresh"
    local events = { "LspAttach", "InsertLeave", "BufReadPost" }

    local ok, autocmds = pcall(vim.api.nvim_get_autocmds, {
      group = group,
      buffer = bufnr,
      event = events,
    })

    if ok and #autocmds > 0 then
      return
    end

    local augroup = vim.api.nvim_create_augroup(group, { clear = false })
    vim.api.nvim_create_autocmd(events, {
      group = group,
      buffer = bufnr,
      callback = function()
        vim.schedule(function()
          if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) == 0 then
            pcall(vim.lsp.codelens.refresh)
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd({ "BufDelete" }, {
      group = group,
      buffer = bufnr,
      callback = function()
        if #vim.lsp.get_clients({ bufnr = bufnr, method = method }) == 0 then
          vim.api.nvim_del_augroup_by_id(augroup)
        end
      end,
    })
  end

  if nvim.lsp.inlay_hints.enabled then
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
  end

  setup.load_keymaps(nvim.lsp.buffer_mappings, { buffer = bufnr })
  for k, v in pairs(nvim.lsp.buffer_options) do
    vim.api.nvim_set_option_value(k, v, { buf = bufnr })
  end
end

function M.get_common_opts()
  return {
    on_attach = M.common_on_attach,
    on_init = M.common_on_init,
    on_exit = M.common_on_exit,
    capabilities = M.common_capabilities(),
  }
end

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@return boolean
function M.should_configure(server_name)
  local skipped_filetypes = nvim.lsp.skipped_filetypes
  local skipped_servers = nvim.lsp.skipped_servers

  if vim.tbl_contains(skipped_servers, server_name) then
    return false
  end

  -- get the supported filetypes and remove any ignored ones
  local filetypes = vim.tbl_filter(function(ft)
    return not vim.tbl_contains(skipped_filetypes, ft)
  end, require("ck.lsp.utils").get_supported_filetypes(server_name) or {})

  if not filetypes or #filetypes == 0 then
    return false
  end

  return true
end

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
          log:debug(("Skipping configuring LSP: %s"):format(server_name))

          return
        end

        require("ck.lsp.loader").setup(server_name)
      end,
    })

    local util = require("lspconfig.util")
    util.on_setup = nil
  end, debug.traceback)

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

  require("ck.lsp.format").setup()
end

return M
