---
-- {
--   "tpope/vim-surround",
--   config = function()
--     require("extensions.vim-surround").setup()
--   end,
--   disable = not lvim.extensions.vim_surround.active,
-- },
local M = {}

local extension_name = "vim_surround"

function M.config()
  lvim.extensions[extension_name] = { active = false, on_config_done = nil }
end

function M.setup()
  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
