local M = {}

M.config = function()
  lvim.builtin.bufferline = {active = true, on_config_done = nil, keymap = {normal_mode = {['<Leader-Left>'] = ':BufferNext<CR>',['<Leader-Up>'] = ':BufferMoveNext<CR>', ['<Leader-Right>'] = ':BufferPrevious<CR>' , ['<Leader-Left>'] = ':BufferMovePrevious<CR>'}}}
end

M.setup = function()
  local keymap = require('keymappings')
  keymap.append_to_defaults(lvim.builtin.bufferline.keymap)

  if lvim.builtin.bufferline.on_config_done then lvim.builtin.bufferline.on_config_done() end
end

return M
