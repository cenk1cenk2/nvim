local M = {}

function M.setup()
  -- only needed to clear when not the default colorscheme
  -- if vim.g.colors_name then
  -- end

  vim.opt.termguicolors = true
  vim.opt.background = "dark"
  vim.g.colors_name = "onedarker"

  vim.cmd("hi clear")

  require("onedarker.highlights").setup()
  require("onedarker.terminal").setup()
end

return M
