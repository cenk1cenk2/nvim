local M = {}

local log = require("ck.log")

---@param folder string
function M.add_to_workspace_folder(folder)
  vim.lsp.buf.add_workspace_folder(folder)
end

---@param folder string
function M.remove_workspace_folder(folder)
  vim.lsp.buf.remove_workspace_folder(folder)
end

function M.list_workspace_folders()
  vim.lsp.buf.list_workspace_folders()
end

---@param opts? vim.lsp.buf.code_action.Opts
function M.code_action(opts)
  vim.lsp.buf.code_action(opts)
end

function M.document_highlight()
  vim.lsp.buf.document_highlight()
end

---@param opts? vim.lsp.ListOpts
function M.document_symbols(opts)
  vim.lsp.buf.document_symbol(opts)
end

---@param opts? vim.lsp.buf.format.Opts
function M.format(opts)
  opts = vim.tbl_extend("force", {
    bufnr = vim.api.nvim_get_current_buf(),
    timeout_ms = nvim.lsp.tools.format.timeout_ms,
    filter = nvim.lsp.tools.format.filter,
  }, opts or {})

  vim.lsp.buf.format(opts)
end

function M.hover()
  vim.lsp.buf.hover()
end

---@param opts? vim.lsp.LocationOpts
function M.declaration(opts)
  vim.lsp.buf.declaration(opts)
  vim.lsp.buf.clear_references()
end

---@param opts? vim.lsp.LocationOpts
function M.definition(opts)
  vim.lsp.buf.definition(opts)
  vim.lsp.buf.clear_references()
end

---@param opts? vim.lsp.LocationOpts
function M.implementation(opts)
  vim.lsp.buf.implementation(opts)
end

function M.incoming_calls()
  vim.lsp.buf.incoming_calls()
end

function M.outgoing_calls()
  vim.lsp.buf.outgoing_calls()
end

---@param context table | nil
---@param opts vim.lsp.ListOpts
function M.references(context, opts)
  vim.lsp.buf.references(context, opts)
end

function M.clear_references()
  vim.lsp.buf.clear_references()
end

---@param opts? vim.lsp.buf.rename.Opts
function M.rename(opts)
  vim.lsp.buf.rename(nil, opts)
end

function M.signature_help()
  vim.lsp.buf.signature_help()
end

---@param opts? vim.lsp.LocationOpts
function M.type_definition(opts)
  vim.lsp.buf.type_definition(opts)
end

---@param query? string
---@param opts? vim.lsp.ListOpts
function M.workspace_symbols(query, opts)
  vim.lsp.buf.workspace_symbol(query, opts)
end

-- diagnostic

---@param opts vim.diagnostic.JumpOpts
function M.jump(opts)
  opts = vim.tbl_deep_extend("force", opts, { float = { border = nvim.lsp.popup_border } })

  vim.diagnostic.jump(opts)
end

function M.show_line_diagnostics()
  local config = nvim.lsp.diagnostics.float
  config.scope = "line"
  vim.diagnostic.open_float(0, config)
end

function M.document_diagonistics()
  require("telescope.builtin").lsp_document_diagnostics()
end

function M.workspace_diagonistics()
  vim.lsp.workspace_diagonistics()
  require("telescope.builtin").lsp_workspace_diagnostics()
end

function M.codelens()
  vim.lsp.codelens.run()
end

---@param opts? vim.diagnostic.setloclist.Opts
function M.diagonistics_set_loclist(opts)
  vim.diagnostic.setloclist(opts)
end

function M.reset_diagnostics()
  vim.diagnostic.reset()
end

---@param filter? vim.lsp.inlay_hint.enable.Filter
function M.toggle_inlay_hints(filter)
  filter = filter or {}
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end

---Reset LSP on given filter.
---@param filter? vim.lsp.get_clients.Filter
---@diagnostic disable-next-line: duplicate-set-field
function M.restart_lsp(filter)
  filter = filter or { bufnr = vim.api.nvim_get_current_buf() }

  local clients = vim.tbl_filter(function(client)
    if vim.tbl_contains({ "copilot", "typos_lsp" }, client.name) then
      return false
    end

    return true
  end, vim.lsp.get_clients(filter))

  for _, client in pairs(clients) do
    vim.schedule(function()
      -- vim.lsp.stop_client(client.id, true)
      vim.cmd(("LspRestart %s"):format(client.id))
    end)
  end

  ---@type table
  local readable = vim.deepcopy(filter)

  if filter.bufnr then
    readable.bufnr = nil
    readable.filename = require("ck.utils.fs").get_project_buffer_filepath(filter.bufnr)
  end

  log:warn(
    "Killed LSPs: %s -> %s",
    table.concat(
      vim.tbl_map(function(client)
        return client.name
      end, clients),
      ", "
    ),
    readable
  )

  -- require("ck.utils").reload_file()
end

function M.fix_current()
  local params = vim.lsp.util.make_range_params()
  params.context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local bufnr = vim.api.nvim_get_current_buf()

  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(responses)
    local fixes = {}

    for client_id, response in pairs(responses) do
      for _, result in pairs(response.result or {}) do
        table.insert(fixes, vim.tbl_extend("force", result, { client_id = client_id }))
      end
    end

    if #fixes == 0 then
      log:warn(("[QUICKFIX] Not found: %s -> %s"):format(
        vim.tbl_map(function(client)
          return client.name
        end, vim.lsp.get_clients({ bufnr = bufnr })),
        responses
      ))

      return
    end

    local tools_client_id = (vim.lsp.get_clients({ name = nvim.lsp.tools.clients.linters })[1] or {}).id

    local lsp_fixes = vim.tbl_filter(function(fix)
      if not fix.edit and not fix.command then
        return false
      end

      if fix.client_id == tools_client_id then
        return false
      end

      return true
    end, fixes)

    local tool_fixes = vim.tbl_filter(function(fix)
      if not fix.edit and not fix.command then
        return false
      end

      if fix.client_id ~= tools_client_id then
        return false
      end

      return true
    end, fixes)

    local fix = lsp_fixes[1] or tool_fixes[1]

    local client = vim.lsp.get_client_by_id(fix.client_id)

    vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", fix.command)

    log:info(("[QUICKFIX] %s: %s"):format((client or {}).name, fix.title or ""))
  end)
end

function M.organize_imports()
  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = {},
    only = { "source.organizeImports" },
  }

  vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(responses)
    if not responses or vim.tbl_isempty(responses) then
      log:warn("No response from language servers.")
      return
    end

    if vim.tbl_count(responses) == 0 then
      log:warn("No language server has answered the organize imports call.")
    end

    for _, response in pairs(responses) do
      if response.error then
        log:warn(response.error.message)
      end

      for _, result in pairs(response.result or {}) do
        vim.lsp.buf_request_sync(0, "workspace/executeCommand", result.command)
      end
    end
  end)
end

function M.rename_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local source = vim.api.nvim_buf_get_name(bufnr)

  local current = vim.api.nvim_buf_get_name(bufnr)
  vim.ui.input({ prompt = "Rename", default = current }, function(rename)
    if not rename then
      vim.notify("File name can not be empty.", vim.log.levels.ERROR)

      return
    end

    local stat = vim.uv.fs_stat(rename)

    if stat and stat.type then
      vim.notify(("File already exists: %s"):format(rename), vim.log.levels.ERROR)

      return
    end

    local files = {
      current = vim.uri_from_fname(current),
      rename = vim.uri_from_fname(rename),
    }

    vim.lsp.buf_request(bufnr, "workspace/willRenameFiles", {
      files = {
        {
          oldUri = files.current,
          newUri = files.rename,
        },
      },
    }, function(error, result, context)
      local client = vim.lsp.get_client_by_id(context.client_id)

      if client == nil then
        log:error("LSP client can not be found: %d", context.client_id)

        return
      end

      if error then
        log:warn("[%s] %s", client.name, error.message)

        return
      end

      if result == nil or #vim.tbl_keys(result) == nil then
        log:warn("No language server has answered the rename call.")

        return
      end

      vim.lsp.util.apply_workspace_edit(result, client.offset_encoding or "utf-8")

      local ok, err = vim.uv.fs_rename(current, rename)
      if not ok then
        log:error(string.format("Failed to move file %s to %s: %s", current, rename, err))
      end

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == source then
          vim.api.nvim_buf_set_name(b, rename)
        end
      end

      vim.notify(("[%s] renamed: %s %s %s"):format(client.name, current, nvim.ui.icons.ui.DoubleChevronRight, rename))
    end)
  end)
end

function M.set_log_level(level)
  vim.lsp.set_log_level(level)
  log:info("Set LSP log level: %s", level)
end

return M
