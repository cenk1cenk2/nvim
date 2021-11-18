local M = {}

M.config = function()
  lvim.builtin.bufferline = {
    active = true,
    on_config_done = nil,
    keymap = {
      normal_mode = {
        ["<M-Right>"] = ":BufferNext<CR>",
        ["<M-Up>"] = ":BufferMoveNext<CR>",
        ["<M-Left>"] = ":BufferPrevious<CR>",
        ["<M-Down>"] = ":BufferMovePrevious<CR>",
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
