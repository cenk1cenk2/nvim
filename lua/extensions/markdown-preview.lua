local M = {}

local extension_name = 'markdown_preview'

function M.config()
  lvim.extensions[extension_name] = {active = true, on_config_done = nil}
end

function M.setup()
  vim.g.mkdp_echo_preview_url = 1
  vim.g.mkdp_open_to_the_world = 1

  vim.g.mkdp_preview_options = {
    mkit = {},
    katex = {},
    uml = {},
    maid = {},
    disable_sync_scroll = 0,
    sync_scroll_type = 'middle',
    hide_yaml_meta = 1,
    sequence_diagrams = {},
    flowchart_diagrams = {},
    content_editable = true
  }

  vim.g.mkdp_port = '15000'
  vim.g.mkdp_page_title = '${name} - preview'

  lvim.builtin.which_key.mappings['a']['m'] = {':MarkdownPreview<CR>', 'markdown preview start'}
  lvim.builtin.which_key.mappings['a']['M'] = {':MarkdownPreviewStop<CR>', 'markdown preview stop'}

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done() end
end

return M
