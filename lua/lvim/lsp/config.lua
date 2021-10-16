return {
  templates_dir = join_paths(get_runtime_dir(), 'site', 'after', 'ftplugin'),
  diagnostics = {
    signs = {
      active = true,
      values = {
        {name = 'LspDiagnosticsSignError', text = ''},
        {name = 'LspDiagnosticsSignWarning', text = ''},
        {name = 'LspDiagnosticsSignHint', text = ''},
        {name = 'LspDiagnosticsSignInformation', text = ''}
      }
    },
    virtual_text = true,
    update_in_insert = false,
    underline = false,
    severity_sort = true
  },
  override = {},
  document_highlight = true,
  code_lens_refresh = true,
  popup_border = 'single',
  on_attach_callback = nil,
  on_init_callback = nil,
  automatic_servers_installation = true,
  buffer_mappings = require('keys.lsp-mappings'),
  null_ls = {setup = {}}
}