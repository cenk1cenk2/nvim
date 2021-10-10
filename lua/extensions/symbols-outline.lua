local M = {}

local extension_name = 'symbols_outline'

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = true,
      position = 'right',
      keymaps = {close = 'q', goto_location = '<Cr>', focus_location = 'o', hover_symbol = '<C-Space>', rename_symbol = 'r', code_actions = 'a'},
      lsp_blacklist = {}
    }
  }
end

function M.setup()

  vim.g[extension_name] = lvim.extensions[extension_name].setup

  lvim.builtin.which_key.mappings['l']['o'] = {':SymbolsOutline<CR>', 'symbols-outline'}

  if lvim.extensions[extension_name].on_config_done then lvim.extensions[extension_name].on_config_done() end
end

return M
