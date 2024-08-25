return {
  templates_dir = join_paths(get_data_dir(), "site", "after", "ftplugin"),
  format_on_save = {
    enable = true,
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 5000,
    ---@usage filter func to select client
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
  code_lens = {
    refresh = true,
  },
  inlay_hints = {
    enabled = true,
  },

  keymaps = require("ck.keys.lsp"),
  ---@type table<string, string>
  buffer_options = {
    --- enable completion triggered by <c-x><c-o>
    omnifunc = "v:lua.vim.lsp.omnifunc",
    --- use gq for formatting
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },

  ---@type string[]
  ensure_installed = {},
  ---@type string[]
  skipped_servers = {},
  ---@type string[]
  skipped_filetypes = {},
  tools = {
    clients = {
      formatters = "",
      linters = "",
    },
    by_ft = {
      ---@type table<LspToolMethods, table<string, string[]>>
      formatters = {},
      ---@type table<LspToolMethods, table<string, string[]>>
      linters = {},
    },
    list_registered = {
      ---@param bufnr number
      ---@return string[]
      formatters = function(bufnr)
        return require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.FORMATTER, bufnr)
      end,
      ---@param bufnr number
      ---@return string[]
      linters = function(bufnr)
        return require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.LINTER, bufnr)
      end,
    },
  },

  fn = {},
  ---@type LspOnCallback[]
  on_init_callbacks = {},
  ---@type LspOnCallback[]
  on_attach_callbacks = {},
  ---@type LspOnCallback[]
  on_exit_callbacks = {},
}
