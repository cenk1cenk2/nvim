local M = {}

M.config = function()
  vim.g.bufferline = { no_name_title = "Empty" }
  lvim.builtin.bufferline = {
    active = true,
    on_config_done = nil,
    keymap = {
      normal_mode = {
        ["<Leader><Right>"] = ":BufferNext<CR>",
        ["<Leader><Down>"] = ":BufferMoveNext<CR>",
        ["<Leader><Left>"] = ":BufferPrevious<CR>",
        ["<Leader><Up>"] = ":BufferMovePrevious<CR>",
      },
    },
  }
end

M.setup = function()
  require("lvim.keymappings").load(lvim.builtin.bufferline.keymap)

  if lvim.builtin.bufferline.on_config_done then
    lvim.builtin.bufferline.on_config_done()
  end
end

return M
