local M = {}

function M.setup()
  -- only needed to clear when not the default colorscheme
  -- if vim.g.colors_name then
  vim.cmd("hi clear")
  -- end

  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "onedarker"

  require("onedarker.highlights").setup()
  require("onedarker.terminal").setup()
end

return M
