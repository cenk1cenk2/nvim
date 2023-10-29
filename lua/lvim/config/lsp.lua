return {
  templates_dir = join_paths(get_data_dir(), "site", "after", "ftplugin"),
  format_on_save = {
    enable = true,
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 5000,
    ---@usage filter func to select client
    filter = require("lvim.lsp.utils").format_filter,
  },
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = lvim.ui.icons.diagnostics.Error },
        { name = "DiagnosticSignWarn", text = lvim.ui.icons.diagnostics.Warning },
        { name = "DiagnosticSignHint", text = lvim.ui.icons.diagnostics.Hint },
        { name = "DiagnosticSignInfo", text = lvim.ui.icons.diagnostics.Information },
      },
    },
    virtual_text = {
      prefix = "",
      source = "always",
    },
    update_in_insert = false,
    underline = false,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = lvim.ui.border,
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          return string.format("%s [%s]", d.message, code):gsub("1. ", "")
        end
        return d.message
      end,
    },
  },
  code_lens = {
    refresh = true,
  },
  -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
  -- Be aware that you also will need to properly configure your LSP server to
  -- provide the inlay hints.
  inlay_hints = {
    enabled = true,
  },
  float = {
    focusable = true,
    style = "minimal",
    border = lvim.ui.border,
  },
  peek = {
    max_height = 36,
    max_width = 180,
    context = 48,
  },
  buffer_mappings = require("keys.lsp"),
  automatic_configuration = {
    ---@usage list of servers that the automatic installer will skip
    skipped_servers = {},
    ---@usage list of filetypes that the automatic installer will skip
    skipped_filetypes = {},
  },
  buffer_options = {
    --- enable completion triggered by <c-x><c-o>
    omnifunc = "v:lua.vim.lsp.omnifunc",
    --- use gq for formatting
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },
  ---@usage list of settings of nvim-lsp-installer
  installer = {
    setup = {
      ensure_installed = {},
      automatic_installation = {
        exclude = {},
      },
    },
  },
  tools = {
    clients = {
      formatters = "",
      linters = "",
    },
    by_ft = {
      formatters = {},
      linters = {},
    },
    list_registered = {
      formatters = function(ft)
        return lvim.lsp.tools.by_ft.formatters[ft] or {}
      end,
      linters = function(ft)
        return lvim.lsp.tools.by_ft.linters[ft] or {}
      end,
    },
  },
  null_ls = {
    setup = {
      debug = false,
    },
    config = {},
  },
  wrapper = {},
  on_init_callbacks = {},
  on_attach_callbacks = {},
  on_exit_callbacks = {},
}
