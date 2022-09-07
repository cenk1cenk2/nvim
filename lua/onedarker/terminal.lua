local M = {}

local c = require "onedarker.colors"

function M.setup()
  vim.g.terminal_color_0 = c.bg[400]
  vim.g.terminal_color_1 = c.red[600]
  vim.g.terminal_color_2 = c.green[600]
  vim.g.terminal_color_3 = c.yellow[600]
  vim.g.terminal_color_4 = c.blue[600]
  vim.g.terminal_color_5 = c.magenta[600]
  vim.g.terminal_color_6 = c.cyan[600]
  vim.g.terminal_color_7 = c.bg[800]
  vim.g.terminal_color_8 = c.bg[500]
  vim.g.terminal_color_9 = c.red[900]
  vim.g.terminal_color_10 = c.green[900]
  vim.g.terminal_color_11 = c.yellow[900]
  vim.g.terminal_color_12 = c.blue[900]
  vim.g.terminal_color_13 = c.magenta[900]
  vim.g.terminal_color_14 = c.cyan[900]
  vim.g.terminal_color_15 = c.bg[900]
  vim.g.terminal_color_16 = c.bg[700]
end

return M
