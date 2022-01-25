local M = {}

local extension_name = "aerojump_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {},
    keymaps = {
      ["<C-p>"] = "AerojumpUp",
      ["<Left>"] = "AerojumpSelPrev",
      ["<C-g>"] = "AerojumpSelPrev",
      ["<C-j>"] = "AerojumpSelect",
      ["<Down>"] = "AerojumpDown",
      ["<C-k>"] = "AerojumpUp",
      ["<Up>"] = "AerojumpUp",
      ["<C-n>"] = "AerojumpDown",
      ["<Right>"] = "AerojumpSelNext",
      ["<C-l>"] = "AerojumpSelNext",
      ["<C-q>"] = "AerojumpExit",
      ["<ESC>"] = "AerojumpSelect",
      ["<CR>"] = "AerojumpSelect",
      ["<Space>"] = "AerojumpSelect",
    },
  }
end

function M.setup()
  vim.g.aerojump_keymaps = lvim.extensions[extension_name].keymaps

  lvim.builtin.which_key.mappings["f"]["a"] = {
    "<Plug>(AerojumpFromCursorBolt)",
    "aerojump",
  }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
