local M = {}
local Log = require("lvim.core.log")
local lsp_utils = require("utils.lsp")

function M.add_to_workspace_folder()
  vim.lsp.buf.add_workspace_folder()
end

function M.code_action(...)
  vim.lsp.buf.code_action(...)
end

function M.document_highlight()
  vim.lsp.buf.document_highlight()
end

function M.document_symbols()
  -- vim.lsp.buf.document_symbol()
  require("telescope.builtin").lsp_document_symbols()
end

function M.format(opts)
  opts = vim.tbl_extend("force", { timeout_ms = lvim.lsp.format_on_save.timeout_ms, filter = lvim.lsp.format_on_save.filter }, opts or {})

  vim.lsp.buf.format(opts)
end

function M.hover()
  vim.lsp.buf.hover()
end

function M.declaration()
  vim.lsp.buf.declaration()
  vim.lsp.buf.clear_references()
end

function M.definition()
  vim.lsp.buf.definition()
  vim.lsp.buf.clear_references()
end

function M.implementation()
  require("telescope.builtin").lsp_implementations()
  -- vim.lsp.buf.implementation()
end

function M.incoming_calls()
  require("telescope.builtin").lsp_incoming_calls()
  -- vim.lsp.buf.incoming_calls()
end

function M.outgoing_calls()
  require("telescope.builtin").lsp_outgoing_calls()
  -- vim.lsp.buf.outgoing_calls()
end

function M.list_workspace_folders()
  vim.lsp.buf.list_workspace_folders()
end

function M.references()
  -- vim.lsp.buf.references()
  require("telescope.builtin").lsp_references()
end

function M.clear_references()
  vim.lsp.buf.clear_references()
end

function M.remove_workspace_folder()
  vim.lsp.buf.remove_workspace_folder()
end

function M.rename()
  vim.lsp.buf.rename()
end

function M.signature_help()
  vim.lsp.buf.signature_help()
end

function M.type_definition()
  vim.lsp.buf.type_definition()
end

function M.workspace_symbols()
  -- vim.lsp.buf.workspace_symbol()

  require("telescope.builtin").lsp_dynamic_workspace_symbols()
end

-- diagnostic

function M.goto_next()
  vim.diagnostic.goto_next({ popup_opts = { border = lvim.lsp.popup_border } })
end

function M.goto_prev()
  vim.diagnostic.goto_prev({ popup_opts = { border = lvim.lsp.popup_border } })
end

function M.show_line_diagnostics()
  local config = lvim.lsp.diagnostics.float
  config.scope = "line"
  vim.diagnostic.open_float(0, config)
end

function M.document_diagonistics()
  require("telescope.builtin").lsp_document_diagnostics()
end

function M.workspace_diagonistics()
  require("telescope.builtin").lsp_workspace_diagnostics()
end

function M.code_lens()
  vim.lsp.codelens.run()
end

function M.diagonistics_set_list()
  vim.diagnostic.set_loclist()
end

function M.reset_diagnostics()
  vim.diagnostic.reset()
end

function M.toggle_inlay_hints()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
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
      Log:warn(("[QUICKFIX] Not found: %s -> %s"):format(
        vim.inspect(vim.tbl_map(function(client)
          return client.name
        end, vim.lsp.get_clients({ bufnr = bufnr }))),
        vim.inspect(responses)
      ))

      return
    end

    local tools_client_id = (vim.lsp.get_clients({ name = lvim.lsp.tools.clients.linters })[1] or {}).id

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

    lsp_utils.apply_lsp_edit(fix)

    Log:info(("[QUICKFIX] %s: %s"):format((client or {}).name, fix.title or ""))
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
      Log:warn("No response from language servers.")
      return
    end

    if vim.tbl_count(responses) == 0 then
      Log:warn("No language server has answered the organize imports call.")
    end

    for _, response in pairs(responses) do
      if response.error then
        Log:warn(response.error.message)
      end

      for _, result in pairs(response.result or {}) do
        lsp_utils.apply_lsp_edit(result)
      end
    end
  end)
end

function M.rename_file()
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  local source = vim.api.nvim_buf_get_name(bufnr)

  local current = vim.api.nvim_buf_get_name(bufnr)
  vim.ui.input({ prompt = "Set the path to rename to" .. " ➜  ", default = current }, function(rename)
    if not rename then
      vim.notify("File name can not be empty.", vim.log.levels.ERROR)

      return
    end

    local stat = vim.uv.fs_stat(rename)

    if stat and stat.type then
      vim.notify("File already exists: " .. rename, vim.log.levels.ERROR)

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
        Log:warn(error.message)
      end

      if result == nil or #vim.tbl_keys(result) == nil then
        Log:warn("No language server has answered the rename call.")

        return
      end

      lsp_utils.apply_lsp_edit(result)

      if vim.fn.getbufvar(bufnr, "&modified") then
        vim.cmd("silent noautocmd w")
      end

      local ok, err = vim.uv.fs_rename(current, rename)
      if not ok then
        Log:error(string.format("Failed to move file %s to %s: %s", current, rename, err))
      end

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == source then
          vim.api.nvim_buf_set_name(b, rename)
        end
      end

      vim.notify(current .. " ➜  " .. rename)
    end)
  end)
end

function M.lsp_logging_level(level)
  vim.lsp.set_log_level(level)
end

function M.setup()
  for key, value in pairs(M) do
    lvim.lsp.wrapper[key] = value
  end

  require("utils.setup").init({
    name = "lsp-wrapper",
    commands = {
      {
        name = "LspLogLevelDebug",
        fn = function()
          M.lsp_logging_level("debug")
        end,
      },
      {
        name = "LspLogLevelInfo",
        fn = function()
          M.lsp_logging_level("info")
        end,
      },
      {
        name = "LspOrganizeImports",
        fn = function()
          M.organize_imports()
        end,
      },
      {
        name = "LspRenameFile",
        fn = function()
          M.rename_file()
        end,
      },
    },
    wk = function(_, categories)
      return {
        ["q"] = {
          function()
            lvim.lsp.wrapper.fix_current()
          end,
          "fix current",
        },
        [categories.LSP] = {
          name = "lsp",
          c = {
            function()
              lvim.lsp.wrapper.incoming_calls()
            end,
            "incoming calls",
          },
          C = {
            function()
              lvim.lsp.wrapper.outgoing_calls()
            end,
            "outgoing calls",
          },
          d = {
            function()
              lvim.lsp.wrapper.document_diagnostics()
            end,
            "document diagnostics",
          },
          D = {
            function()
              lvim.lsp.wrapper.workspace_diagnostics()
            end,
            "workspace diagnostics",
          },
          f = {
            function()
              lvim.lsp.wrapper.format()
            end,
            "format buffer",
          },
          F = { ":LvimToggleFormatOnSave<CR>", "toggle autoformat" },
          g = { ":LspOrganizeImports<CR>", "organize imports" },
          G = { ":LspAddMissingImports<CR>", "add all missing imports" },
          i = {
            function()
              require("lvim.lsp.info").toggle(vim.bo.filetype)
            end,
            "lsp info",
          },
          I = { ":Mason<CR>", "lsp installer" },
          m = { ":LspRenameFile<CR>", "rename file with lsp" },
          h = { ":LspImportAll<CR>", "import all missing" },
          H = { ":LspImportCurrent<CR>", "import current" },
          n = {
            function()
              lvim.lsp.wrapper.goto_next()
            end,
            "next diagnostic",
          },
          p = {
            function()
              lvim.lsp.wrapper.goto_prev()
            end,
            "prev diagnostic",
          },
          l = {
            function()
              lvim.lsp.wrapper.code_lens()
            end,
            "codelens",
          },
          r = {
            function()
              lvim.lsp.wrapper.rename()
            end,
            "rename item under cursor",
          },
          q = {
            function()
              lvim.lsp.wrapper.diagonistics_set_list()
            end,
            "set quickfix list",
          },
          s = {
            function()
              lvim.lsp.wrapper.document_symbols()
            end,
            "document symbols",
          },
          S = {
            function()
              lvim.lsp.wrapper.workspace_symbols()
            end,
            "workspace symbols",
          },
          ["t"] = {
            function()
              lvim.lsp.wrapper.toggle_inlay_hints()
            end,
            "toggle inlay hints",
          },
          ["R"] = {
            function()
              lvim.lsp.wrapper.reset_diagnostics()
            end,
            "reset diagnostics",
          },
          Q = {
            function()
              vim.cmd("LspRestart")

              vim.fn.system({ "pkill", "-9", "terraform-ls" })
            end,
            "restart currently active lsps",
          },
        },
      }
    end,
  })
end

return M
