local M = {}

local log = require("ck.log")
local utils = require("ck.lsp.utils")

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.add_to_workspace_folder()
  vim.lsp.buf.add_workspace_folder()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.remove_workspace_folder()
  vim.lsp.buf.remove_workspace_folder()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.list_workspace_folders()
  vim.lsp.buf.list_workspace_folders()
end

---@param ... vim.lsp.buf.code_action.Opts
---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.code_action(...)
  vim.lsp.buf.code_action(...)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.document_highlight()
  vim.lsp.buf.document_highlight()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.document_symbols()
  require("telescope.builtin").lsp_document_symbols()
end

---@param opts vim.lsp.buf.format.Opts
---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.format(opts)
  opts = vim.tbl_extend("force", {
    bufnr = vim.api.nvim_get_current_buf(),
    timeout_ms = nvim.lsp.format_on_save.timeout_ms,
    filter = nvim.lsp.format_on_save.filter,
  }, opts or {})

  vim.lsp.buf.format(opts)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.hover()
  vim.lsp.buf.hover()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.declaration()
  vim.lsp.buf.declaration()
  vim.lsp.buf.clear_references()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.definition()
  vim.lsp.buf.definition()
  vim.lsp.buf.clear_references()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.implementation()
  require("telescope.builtin").lsp_implementations()
  -- vim.lsp.buf.implementation()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.incoming_calls()
  require("telescope.builtin").lsp_incoming_calls()
  -- vim.lsp.buf.incoming_calls()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.outgoing_calls()
  require("telescope.builtin").lsp_outgoing_calls()
  -- vim.lsp.buf.outgoing_calls()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.references()
  -- vim.lsp.buf.references()
  require("telescope.builtin").lsp_references()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.clear_references()
  vim.lsp.buf.clear_references()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.rename()
  vim.lsp.buf.rename()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.signature_help()
  vim.lsp.buf.signature_help()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.type_definition()
  vim.lsp.buf.type_definition()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.workspace_symbols()
  -- vim.lsp.buf.workspace_symbol()

  require("telescope.builtin").lsp_dynamic_workspace_symbols()
end

-- diagnostic

---@param opts vim.diagnostic.JumpOpts
---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.jump(opts)
  opts = opts or {}

  opts = vim.tbl_deep_extend("force", opts, { float = { border = nvim.lsp.popup_border } })

  vim.diagnostic.jump(opts)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.show_line_diagnostics()
  local config = nvim.lsp.diagnostics.float
  config.scope = "line"
  vim.diagnostic.open_float(0, config)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.document_diagonistics()
  require("telescope.builtin").lsp_document_diagnostics()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.workspace_diagonistics()
  require("telescope.builtin").lsp_workspace_diagnostics()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.code_lens()
  vim.lsp.codelens.run()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.diagonistics_set_loclist()
  vim.diagnostic.setloclist()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.reset_diagnostics()
  vim.diagnostic.reset()
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.toggle_inlay_hints()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(bufnr), { bufnr = bufnr })
end

---Reset LSP on given filter.
---@param filter? vim.lsp.get_clients.Filter
---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.restart_lsp(filter)
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

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.fix_current()
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

    utils.apply_lsp_edit(fix)

    log:info(("[QUICKFIX] %s: %s"):format((client or {}).name, fix.title or ""))
  end)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.organize_imports()
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
        utils.apply_lsp_edit(result)
      end
    end
  end)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.rename_file()
  local win = vim.api.nvim_get_current_win()
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
      current = ("file://%s"):format(current),
      rename = ("file://%s"):format(rename),
    }

    vim.lsp.buf_request(bufnr, "workspace/willRenameFiles", {
      files = {
        {
          oldUri = files.current,
          newUri = files.rename,
        },
      },
    }, function(error, result, _context, _config)
      if error then
        log:warn(error.message)
      end

      if result == nil or #vim.tbl_keys(result) == nil then
        log:warn("No language server has answered the rename call.")

        return
      end

      utils.apply_lsp_edit(result)

      if vim.fn.getbufvar(bufnr, "&modified") then
        vim.cmd("silent noautocmd w")
      end

      local ok, err = vim.uv.fs_rename(current, rename)
      if not ok then
        log:error(string.format("Failed to move file %s to %s: %s", current, rename, err))
      end

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == source then
          vim.api.nvim_buf_set_name(b, rename)
        end
      end

      vim.notify(("%s %s %s"):format(current, nvim.ui.icons.ui.BoldArrowRight, rename))
    end)
  end)
end

---@diagnostic disable-next-line: duplicate-set-field
function nvim.lsp.fn.lsp_logging_level(level)
  vim.lsp.set_log_level(level)
end

function M.setup()
  require("ck.setup").init({
    commands = {
      {
        "LspLogLevelDebug",
        function()
          nvim.lsp.fn.lsp_logging_level("debug")
        end,
      },
      {
        "LspLogLevelInfo",
        function()
          nvim.lsp.fn.lsp_logging_level("info")
        end,
      },
      {
        "LspOrganizeImports",
        function()
          nvim.lsp.fn.organize_imports()
        end,
      },
      {
        "LspRenameFile",
        function()
          nvim.lsp.fn.rename_file()
        end,
      },
    },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ "q" }),
          function()
            nvim.lsp.fn.fix_current()
          end,
          desc = "fix current",
        },
        {
          fn.wk_keystroke({ categories.LSP, "c" }),
          function()
            nvim.lsp.fn.incoming_calls()
          end,
          desc = "incoming calls",
        },
        {
          fn.wk_keystroke({ categories.LSP, "C" }),
          function()
            nvim.lsp.fn.outgoing_calls()
          end,
          desc = "outgoing calls",
        },
        {
          fn.wk_keystroke({ categories.LSP, "d" }),
          function()
            nvim.lsp.fn.document_diagnostics()
          end,
          desc = "document diagnostics",
        },
        {
          fn.wk_keystroke({ categories.LSP, "D" }),
          function()
            nvim.lsp.fn.workspace_diagnostics()
          end,
          desc = "workspace diagnostics",
        },
        {
          fn.wk_keystroke({ categories.LSP, "f" }),
          function()
            nvim.lsp.fn.format()
          end,
          desc = "format buffer",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.LSP, "F" }),
          function()
            require("ck.lsp.format").toggle_format_on_save()
          end,
          desc = "toggle autoformat",
        },
        {
          fn.wk_keystroke({ categories.LSP, "g" }),
          function()
            vim.cmd([[LspOrganizeImports]])
          end,
          desc = "organize imports",
        },
        {
          fn.wk_keystroke({ categories.LSP, "G" }),
          function()
            vim.cmd([[LspAddMissingImports]])
          end,
          desc = "add all missing imports",
        },
        {
          fn.wk_keystroke({ categories.LSP, "i" }),
          function()
            vim.cmd([[LspInfo]])
          end,
          desc = "lsp info",
        },
        {
          fn.wk_keystroke({ categories.LSP, "I" }),
          function()
            vim.cmd([[Mason]])
          end,
          desc = "lsp installer",
        },
        {
          fn.wk_keystroke({ categories.LSP, "m" }),
          function()
            vim.cmd([[LspRenameFile]])
          end,
          desc = "rename file with lsp",
        },
        {
          fn.wk_keystroke({ categories.LSP, "h" }),
          function()
            vim.cmd([[LspImportAll]])
          end,
          desc = "import all missing",
        },
        {
          fn.wk_keystroke({ categories.LSP, "H" }),
          function()
            vim.cmd([[LspImportCurrent]])
          end,
          desc = "import current missing",
        },
        {
          fn.wk_keystroke({ categories.LSP, "n" }),
          function()
            nvim.lsp.fn.jump({ count = 1, severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } })
          end,
          desc = "next diagnostic (error, warn)",
        },
        {
          fn.wk_keystroke({ categories.LSP, "N" }),
          function()
            nvim.lsp.fn.jump({ count = 1, severity = { vim.diagnostic.severity.INFO, vim.diagnostic.severity.HINT } })
          end,
          desc = "next diagnostic (info, hint)",
        },
        {
          fn.wk_keystroke({ categories.LSP, "p" }),
          function()
            nvim.lsp.fn.jump({ count = -1, severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } })
          end,
          desc = "prev diagnostic (error, warn)",
        },
        {
          fn.wk_keystroke({ categories.LSP, "P" }),
          function()
            nvim.lsp.fn.jump({ count = -1, severity = { vim.diagnostic.severity.INFO, vim.diagnostic.severity.HINT } })
          end,
          desc = "prev diagnostic (info, hint)",
        },
        {
          fn.wk_keystroke({ categories.LSP, "l" }),
          function()
            nvim.lsp.fn.code_lens()
          end,
          desc = "codelens",
        },
        {
          fn.wk_keystroke({ categories.LSP, "r" }),
          function()
            nvim.lsp.fn.rename()
          end,
          desc = "rename item under cursor",
        },
        {
          fn.wk_keystroke({ categories.LSP, "q" }),
          function()
            nvim.lsp.fn.diagonistics_set_loclist()
          end,
          desc = "set location list",
        },
        {
          fn.wk_keystroke({ categories.LSP, "s" }),
          function()
            nvim.lsp.fn.document_symbols()
          end,
          desc = "document symbols",
        },
        {
          fn.wk_keystroke({ categories.LSP, "S" }),
          function()
            nvim.lsp.fn.workspace_symbols()
          end,
          desc = "workspace symbols",
        },
        {
          fn.wk_keystroke({ categories.LSP, "t" }),
          function()
            nvim.lsp.fn.toggle_inlay_hints()
          end,
          desc = "toggle inlay hints",
        },
        {
          fn.wk_keystroke({ categories.LSP, "R" }),
          function()
            nvim.lsp.fn.reset_diagnostics()
          end,
          desc = "reset diagnostics",
        },
        {
          fn.wk_keystroke({ categories.LSP, "Q" }),
          group = "restart",
        },
        {
          fn.wk_keystroke({ categories.LSP, "Q", "Q" }),
          function()
            nvim.lsp.fn.restart_lsp()
          end,
          desc = "restart currently active LSPs for this buffer",
        },
        {
          fn.wk_keystroke({ categories.LSP, "Q", "q" }),
          function()
            nvim.lsp.fn.restart_lsp({})
          end,
          desc = "restart currently active LSPs",
        },
      }
    end,
  })
end

return M
