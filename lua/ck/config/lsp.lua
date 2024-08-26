return {
  format_on_save = {
    enable = true,
    pattern = { "*" },
    timeout = 5000,
    filter = require("ck.lsp.format").filter,
  },
  --- @type vim.diagnostic.Opts
  diagnostics = {
    signs = {
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      text = {
        [vim.diagnostic.severity.ERROR] = nvim.ui.icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = nvim.ui.icons.diagnostics.Warning,
        [vim.diagnostic.severity.INFO] = nvim.ui.icons.diagnostics.Information,
        [vim.diagnostic.severity.HINT] = nvim.ui.icons.diagnostics.Hint,
      },
    },
    virtual_text = {
      severity_sort = true,
      -- prefix = function(diagnostic)
      --   return signs[vim.diagnostic.severity[diagnostic.severity]]
      -- end,
      source = true,
    },
    update_in_insert = false,
    underline = false,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = nvim.ui.border,
      source = true,
      header = "",
      prefix = "",
      format = function(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          local match = string.format("%s [%s]", d.message, code):gsub("1. ", "")

          return match
        end
        return d.message
      end,
    },
  },
  codelens = {
    refresh = true,
  },
  inlay_hints = {
    enabled = true,
  },
  copilot = {
    ---@type "inline" | "cmp"
    completion = "inline",
    ---@type table<string, boolean>
    filetypes = {},
  },

  ---@type table<string, string | LspOnCallback>
  buffer_options = {
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },

  ---@type string[]
  ensure_installed = {},
  ---@type string[]
  skipped_servers = {},
  ---@type string[]
  skipped_filetypes = {},
  ---@usage Automatic update of the language servers on startup.
  automatic_update = true,

  tools = {
    clients = {
      formatters = "",
      linters = "",
    },
    ---@alias ToolByFt table<LspToolMethods, table<string, string[]>>
    by_ft = {
      ---@type ToolByFt
      formatters = {},
      ---@type ToolByFt
      linters = {},
    },
    ---@alias ToolListFn fun(bufnr: number): string[]
    list_registered = {
      ---@type ToolListFn
      formatters = function(bufnr)
        return require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.FORMATTER, bufnr)
      end,
      ---@type ToolListFn
      linters = function(bufnr)
        return require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.LINTER, bufnr)
      end,
    },
  },

  ---@type LspOnCallback[]
  on_init = {},
  ---@type LspOnCallback[]
  on_attach_callbacks = {},
  ---@type LspOnCallback[]
  on_exit_callbacks = {},

  fn = require("ck.lsp.fn"),
}
