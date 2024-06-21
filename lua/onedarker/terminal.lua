local M = {}

local c = require("onedarker.colors")

function M.setup()
  vim.g.terminal_color_0 = c.bg[400] -- black
  vim.g.terminal_color_1 = c.red[600] -- red
  vim.g.terminal_color_2 = c.green[600] -- green
  vim.g.terminal_color_3 = c.yellow[600] -- yellow
  vim.g.terminal_color_4 = c.blue[600] -- blue
  vim.g.terminal_color_5 = c.magenta[600] -- purple
  vim.g.terminal_color_6 = c.cyan[600] -- cyan
  vim.g.terminal_color_7 = c.grey[900] -- white
  vim.g.terminal_color_8 = c.bg[500] -- bright black
  vim.g.terminal_color_9 = c.red[900] -- bright red
  vim.g.terminal_color_10 = c.green[900] -- bright green
  vim.g.terminal_color_11 = c.yellow[900] -- bright yellow
  vim.g.terminal_color_12 = c.blue[900] -- bright blue
  vim.g.terminal_color_13 = c.magenta[900] -- bright magenta
  vim.g.terminal_color_14 = c.cyan[900] -- bright cyan
  vim.g.terminal_color_15 = c.bg[900] -- bright grey
  vim.g.terminal_color_16 = c.white -- bright white
end

return M
