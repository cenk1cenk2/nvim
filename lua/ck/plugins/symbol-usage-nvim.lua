-- https://github.com/Wansmer/symbol-usage.nvim
local M = {}

M.name = "Wansmer/symbol-usage.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Wansmer/symbol-usage.nvim",
        event = "LspAttach",
      }
    end,
    setup = function()
      local SymbolKind = vim.lsp.protocol.SymbolKind
      local kinds = {
        SymbolKind.Package,
        SymbolKind.Namespace,
        SymbolKind.Module,
        SymbolKind.Function,
        SymbolKind.Method,
        SymbolKind.Class,
        -- SymbolKind.Enum,
        SymbolKind.EnumMember,
        SymbolKind.Interface,
        SymbolKind.Struct,
        SymbolKind.TypeParameter,
      }

      ---@type UserOpts
      return {
        kinds = kinds,
        ---Additional filter for kinds. Recommended use in the filetypes override table.
        ---fiterKind: function(data: { symbol:table, parent:table, bufnr:integer }): boolean
        ---`symbol` and `parent` is an item from `textDocument/documentSymbol` request
        ---See: #filter-kinds
        kinds_filter = {},
        vt_position = "end_of_line",
        ---Text to display when request is pending. If `false`, extmark will not be
        ---created until the request is finished. Recommended to use with `above`
        ---vt_position to avoid "jumping lines".
        request_pending_text = false,
        -- request_pending_text = nvim.ui.icons.misc.Watch,
        ---The function can return a string to which the highlighting group from `opts.hl` is applied.
        ---Alternatively, it can return a table of tuples of the form `{ { text, hl_group }, ... }`` - in this case the specified groups will be applied.
        ---See `#format-text-examples`
        text_format = M.text_format,
        references = { enabled = true, include_declaration = false },
        definition = { enabled = false },
        implementation = { enabled = true },
        disable = { lsp = { "yamlls", "lua_ls", "dockerls" }, filetypes = {} },
        filetypes = {
          typescript = {
            kinds = kinds,
          },
          javascript = {
            kinds = kinds,
          },
        },
        symbol_request_pos = "end", -- Recommended redifine only in `filetypes` override table)
      }
    end,
    on_setup = function(c)
      require("symbol-usage").setup(c)
    end,
    hl = function(_, fn)
      -- local h = fn.get_highlight

      return {
        -- ["SymbolUsageRef"] = { bg = h("Type").fg, fg = h("Normal").bg, bold = true },
        -- ["SymbolUsageRefRound"] = { fg = h("Type").fg },
        -- ["SymbolUsageDef"] = { bg = h("Function").fg, fg = h("Normal").bg, bold = true },
        -- ["SymbolUsageDefRound"] = { fg = h("Function").fg },
        -- ["SymbolUsageImpl"] = { bg = h("@parameter").fg, fg = h("Normal").bg, bold = true },
        -- ["SymbolUsageImplRound"] = { fg = h("@parameter").fg },
      }
    end,
  })
end

function M.text_format(symbol)
  local res = {}

  if symbol.references then
    table.insert(res, { ("%s %s"):format(nvim.ui.icons.kind.Reference, tostring(symbol.references)), "SymbolUsageRef" })
  end

  if symbol.definition then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, { ("%s %s"):format(nvim.ui.icons.kind.Interface, tostring(symbol.definition)), "SymbolUsageDef" })
  end

  if symbol.implementation then
    if #res > 0 then
      table.insert(res, { " ", "NonText" })
    end
    table.insert(res, { ("%s %s"):format(nvim.ui.icons.kind.Function, tostring(symbol.implementation)), "SymbolUsageImpl" })
  end

  return res
end

return M
