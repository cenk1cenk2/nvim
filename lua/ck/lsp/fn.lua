local M = {}

local log = require("ck.log")
local fs = require("ck.utils.fs")

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
    timeout_ms = nvim.lsp.tools.format.timeout,
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

---@param filter? vim.lsp.capability.enable.Filter
function M.toggle_inlay_hints(filter)
  filter = filter or {}
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end

---@param filter? vim.lsp.capability.enable.Filter
function M.toggle_inline_completion(filter)
  filter = filter or {}

  vim.lsp.inline_completion.enable(not vim.lsp.inline_completion.is_enabled(filter), filter)
end

---@param bufnr? number
function M.previous_inline_completion(bufnr)
  vim.lsp.inline_completion.select({ bufnr = bufnr, count = -1, wrap = true })
end

---@param bufnr? number
function M.next_inline_completion(bufnr)
  vim.lsp.inline_completion.select({ bufnr = bufnr, count = 1, wrap = true })
end

---@param opts? vim.lsp.inline_completion.get.Opts
function M.accept_inline_completion(opts)
  opts = opts or { bufnr = vim.api.nvim_get_current_buf() }

  if vim.lsp.inline_completion.get(opts) then
    return
  end

  M.trigger_inline_completion(opts)
end

---@param opts? vim.lsp.inline_completion.get.Opts
function M.trigger_inline_completion(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

  -- Ensure buffer is valid
  if not vim.api.nvim_buf_is_valid(bufnr) then
    log:warn("Invalid buffer for inline completion: %d", bufnr)
    return
  end

  local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), "utf-8")

  -- Get buffer options for formatting
  local shiftwidth = vim.bo[bufnr].shiftwidth
  local tabstop = vim.bo[bufnr].tabstop
  local expandtab = vim.bo[bufnr].expandtab

  -- Use shiftwidth if set, otherwise fall back to tabstop
  local tab_size = shiftwidth > 0 and shiftwidth or tabstop

  params.context = {
    triggerKind = 1, -- InlineCompletionTriggerKind.Invoked
    triggerCharacter = nil,
  }

  -- Standard LSP FormattingOptions
  params.formattingOptions = {
    tabSize = tab_size,
    insertSpaces = expandtab,
  }

  vim.lsp.buf_request_all(bufnr, "textDocument/inlineCompletion", params, function(responses)
    for client_id, response in pairs(responses) do
      local client = vim.lsp.get_client_by_id(client_id) or {}

      if response.err then
        log:warn("[%s]: %s", client.name or client.id, response.err.message)
      end
    end
  end)
end

---@param bufnr? number
function M.reject_inline_completion(bufnr)
  log:warn("Not in the spec yet therefore not implemented.")
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
      if not client.name then
        log:warn("LSP client has no name: %d", client.id)

        return
      end
      vim.cmd(([[lsp restart %s]]):format(client.name))
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
  local params = vim.lsp.util.make_range_params(vim.api.nvim_get_current_win(), "utf-8")
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
      log:warn(
        "[QUICKFIX] Not found: %s",
        table.concat(
          vim.tbl_map(function(client)
            return client.name
          end, vim.lsp.get_clients({ bufnr = bufnr })),
          ", "
        )
      )

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

    local client = vim.lsp.get_client_by_id(fix.client_id) or {}

    if fix.edit then
      vim.lsp.util.apply_workspace_edit(fix.edit, client.offset_encoding or "utf-8")
    elseif fix.command then
      vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", fix.command)
    end

    log:info(("[QUICKFIX] %s: %s"):format(client.name, fix.title or ""))
  end)
end

function M.remove_unused_imports()
  return M.call_clients_for_code_action({ "source.removeUnusedImports", "source.removeUnused.ts" }, nil, { "eslint" })
end

function M.add_missing_imports()
  return M.call_clients_for_code_action({ "source.addMissingImports" }, nil, { "eslint" })
end

---
---@param context: table<string>
---@param cb? fun(): nil
---@param ignored? table<string>
function M.call_clients_for_code_action(context, cb, ignored)
  local params = vim.lsp.util.make_range_params(vim.api.nvim_get_current_win(), "utf-8")
  params.context = {
    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
    only = context,
  }

  vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(responses)
    if not responses or vim.tbl_isempty(responses) then
      log:warn("No response from language servers.")
      return
    end

    if vim.tbl_count(responses) == 0 then
      log:warn("No language server has answered: %s", context)
    end

    for client_id, response in pairs(responses) do
      if response.error then
        log:warn(response.error.message)
      end

      for _, result in pairs(response.result or {}) do
        local client = vim.lsp.get_client_by_id(client_id) or {}

        if ignored and vim.tbl_contains(ignored, client.name) then
          log:debug("Ignored client: %s -> %s", client.name, context)

          return
        end

        if result.command then
          vim.lsp.buf_request_sync(0, "workspace/executeCommand", result.command)
        elseif result.edit then
          vim.lsp.util.apply_workspace_edit(result.edit, client.offset_encoding or "utf-8")
        end

        if cb then
          cb()
        end

        log:info("[%s]: %s", client.name, context)
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
        log:warn("[RENAME] %s: %s", client.name, error.message)

        return
      end

      if result == nil or #vim.tbl_keys(result) == nil then
        log:warn("No language server has answered the rename call.")

        return
      end

      vim.lsp.util.apply_workspace_edit(result, client.offset_encoding or "utf-8")

      local ok, err = vim.uv.fs_rename(current, rename)
      if not ok then
        log:error(
          string.format("Failed to move file : %s %s %s -> %s", fs.get_project_filepath(current), nvim.ui.icons.ui.DoubleChevronRight, fs.get_project_filepath(rename), err)
        )
      end

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == source then
          vim.api.nvim_buf_set_name(b, rename)
        end
      end

      vim.notify(("[RENAME] %s: %s %s %s"):format(client.name, fs.get_project_filepath(current), nvim.ui.icons.ui.DoubleChevronRight, fs.get_project_filepath(rename)))
    end)
  end)
end

---
---@param level number
function M.set_log_level(level)
  vim.lsp.log.set_level(level)

  if level ~= log:to_level(nvim.lsp.log.level) then
    log:info("Set LSP log level: %s", level)
  else
    log:debug("Set LSP log level to default: %s", level)
  end
end

return M
