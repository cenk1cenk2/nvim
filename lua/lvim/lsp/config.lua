return {
  templates_dir = join_paths(get_runtime_dir(), "site", "after", "ftplugin"),
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInformation", text = "" },
      },
    },
    virtual_text = true,
    update_in_insert = false,
    underline = false,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local t = vim.deepcopy(d)
        if d.code then
          t.message = string.format("%s [%s]", t.message, t.code):gsub("1. ", "")
        end
        return t.message
      end,
    },
  },
  document_highlight = true,
  code_lens_refresh = true,
  popup_border = "single",
  on_attach_callback = nil,
  on_init_callback = nil,
  automatic_servers_installation = true,
  buffer_mappings = require "keys.lsp-mappings",
  null_ls = {
    setup = {},
    config = {},
  },
  override = {
    "angularls",
    "ansiblels",
    "ccls",
    "csharp_ls",
    "denols",
    "ember",
    "emmet_ls",
    "eslint",
    "eslintls",
    "graphql",
    "jedi_language_server",
    "ltex",
    "phpactor",
    "pylsp",
    "quick_lint_js",
    "rome",
    "sorbet",
    "sqlls",
    "sqls",
    "solang",
    "spectral",
    "stylelint_lsp",
    "tailwindcss",
    "tflint",
    "volar",
  },
}
