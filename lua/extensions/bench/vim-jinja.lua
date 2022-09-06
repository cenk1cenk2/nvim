-- {
--   "lepture/vim-jinja",
--   config = function()
--     require("extensions.vim-jinja").setup()
--   end,
--   disable = not lvim.extensions.vim_jinja.active,
-- },
local M = {}

local extension_name = "vim_jinja"

function M.config()
  lvim.extensions[extension_name] = { active = false, on_config_done = nil }
end

function M.setup()
  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
