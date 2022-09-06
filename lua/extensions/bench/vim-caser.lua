-- {
--   "arthurxavierx/vim-caser",
--   config = function()
--     require("extensions.vim-caser").setup()
--   end,
--   disable = not lvim.extensions.vim_caser.active,
-- },
local M = {}

local extension_name = "vim_caser"

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {
      caser_prefix = "gs",
    },
  }
end

function M.setup()
  vim.g.caser_prefix = lvim.extensions[extension_name].setup.caser_prefix

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
