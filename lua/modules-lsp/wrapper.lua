local M = {}
local Log = require "lvim.core.log"
local lsp_utils = require "utils.lsp"
local table_utils = require "lvim.utils.table"

-- buf

function M.add_to_workspace_folder()
  vim.lsp.buf.add_workspace_folder()
end

function M.clear_references()
  vim.lsp.buf.clear_references()
end

function M.code_action()
  vim.lsp.buf.code_action()
end

function M.declaration()
  vim.lsp.buf.declaration()
  vim.lsp.buf.clear_references()
end

function M.definition()
  vim.lsp.buf.definition()
  vim.lsp.buf.clear_references()
end

function M.document_highlight()
  vim.lsp.buf.document_highlight()
end

function M.document_symbol()
  -- vim.lsp.buf.document_symbol()
  vim.api.nvim_exec("Telescope", { "lsp_document_symbols" })
end

function M.format()
  require("lvim.lsp.utils").format()
end

function M.hover()
  vim.lsp.buf.hover()
end

function M.implementation()
  vim.lsp.buf.implementation()
end

function M.incoming_calls()
  vim.lsp.buf.incoming_calls()
end

function M.list_workspace_folders()
  vim.lsp.buf.list_workspace_folders()
end

function M.outgoing_calls()
  vim.lsp.buf.outgoing_calls()
end

function M.range_code_action()
  vim.lsp.buf.range_code_action()
end

function M.range_formatting()
  vim.lsp.buf.range_formatting()
end

function M.references()
  vim.lsp.buf.references()
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

function M.workspace_symbol()
  -- vim.lsp.buf.workspace_symbol()

  vim.api.nvim_exec("Telescope", { "lsp_dynamic_workspace_symbols" })
end

-- diagnostic

function M.get_all()
  vim.diagnostic.get_all()
end

function M.get_next()
  vim.diagnostic.get_next()
end

function M.get_prev()
  vim.diagnostic.get_prev()
end

function M.goto_next()
  vim.diagnostic.goto_next { popup_opts = { border = lvim.lsp.popup_border } }
end

function M.goto_prev()
  vim.diagnostic.goto_prev { popup_opts = { border = lvim.lsp.popup_border } }
end

function M.show_line_diagnostics()
  local config = lvim.lsp.diagnostics.float
  config.scope = "line"
  vim.diagnostic.open_float(0, config)
end

function M.peek_definition()
  require("lvim.lsp.peek").Peek "definition"
end

function M.peek_type()
  require("lvim.lsp.peek").Peek "typeDefinition"
end

function M.peek_implementation()
  require("lvim.lsp.peek").Peek "implementation"
end

function M.document_diagonistics()
  vim.api.nvim_exec("Telescope", { "lsp_document_diagnostics" })
end

function M.workspace_diagonistics()
  vim.api.nvim_exec("Telescope", { "lsp_workspace_diagnostics" })
end

function M.code_lens()
  vim.lsp.codelens.run()
end

function M.diagonistics_set_list()
  vim.diagnostic.set_loclist()
end

function M.fix_current()
  local params = vim.lsp.util.make_range_params()
  params.context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }

  local responses = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)

  if not responses or vim.tbl_isempty(responses) then
    Log:warn "No quickfix found."
    return
  end

  for i, response in pairs(responses) do
    for _, result in pairs(response.result or {}) do
      Log:info("Applying quickfix from " .. vim.lsp.buf_get_clients()[i].name .. ": " .. result.title)

      lsp_utils.apply_lsp_edit(result)

      break
    end
    break
  end
end

function M.organize_imports()
  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = {},
    only = { "source.organizeImports" },
  }

  local responses = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 2000)

  if not responses or vim.tbl_isempty(responses) then
    Log:warn "No response from language servers."
    return
  end

  if table_utils.length(responses) == 0 then
    Log:warn "No language server has answered the organize imports call."
  end

  for _, response in pairs(responses) do
    if response.error then
      Log:warn(response.error.message)
    end

    for _, result in pairs(response.result or {}) do
      lsp_utils.apply_lsp_edit(result)
    end
  end
end

function M.lsp_logging_level(level)
  vim.lsp.set_log_level(level)
end

function M.setup()
  require("utils.command").create_commands {
    {
      name = "LspCodeAction",
      fn = function()
        M.code_action()
      end,
    },
    {
      name = "LspDeclaration",
      fn = function()
        M.declaration()
      end,
    },
    {
      name = "LspDefinition",
      fn = function()
        M.definition()
      end,
    },
    {
      name = "LspDocumentSymbol",
      fn = function()
        M.document_symbol()
      end,
    },
    {
      name = "LspFormat",
      fn = function()
        M.format()
      end,
    },
    {
      name = "LspHover",
      fn = function()
        M.hover()
      end,
    },
    {
      name = "LspImplementation",
      fn = function()
        M.implementation()
      end,
    },
    {
      name = "LspRangeCodeAction",
      fn = function()
        M.range_code_action()
      end,
    },
    {
      name = "LspRangeFormatting",
      fn = function()
        M.range_formatting()
      end,
    },
    {
      name = "LspReferences",
      fn = function()
        M.references()
      end,
    },
    {
      name = "LspRename",
      fn = function()
        M.rename()
      end,
    },
    {
      name = "LspTypeDefinition",
      fn = function()
        M.type_definition()
      end,
    },
    {
      name = "LspWorkspaceSymbol",
      fn = function()
        M.workspace_symbol()
      end,
    },
    {
      name = "LspGotoNext",
      fn = function()
        M.goto_next()
      end,
    },
    {
      name = "LspGotoPrev",
      fn = function()
        M.goto_prev()
      end,
    },
    {
      name = "LspShowLineDiagnostics",
      fn = function()
        M.show_line_diagnostics()
      end,
    },
    {
      name = "LspLogLevelDebug",
      fn = function()
        M.lsp_logging_level "debug"
      end,
    },
    {
      name = "LspLogLevelInfo",
      fn = function()
        M.lsp_logging_level "info"
      end,
    },
    {
      name = "LspFixCurrent",
      fn = function()
        M.fix_current()
      end,
    },
    {
      name = "LspOrganizeImports",
      fn = function()
        M.organize_imports()
      end,
    },
    {
      name = "LspPeekDefinition",
      fn = function()
        M.peek_definition()
      end,
    },
    {
      name = "LspPeekType",
      fn = function()
        M.peek_type()
      end,
    },
    {
      name = "LspPeekImplementation",
      fn = function()
        M.peek_implementation()
      end,
    },
    {
      name = "LspDocumentDiagonistics",
      fn = function()
        M.document_diagonistics()
      end,
    },
    {
      name = "LspWorkspaceDiagonistics",
      fn = function()
        M.workspace_diagonistics()
      end,
    },
    {
      name = "LspCodeLens",
      fn = function()
        M.code_lens()
      end,
    },
    {
      name = "LspDiagonisticsSetList",
      fn = function()
        M.diagonistics_set_list()
      end,
    },
    {
      name = "LspSignatureHelp",
      fn = function()
        M.signature_help()
      end,
    },
  }
end

return M
