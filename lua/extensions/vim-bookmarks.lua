local M = {}

local extension_name = "vim_bookmarks"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }
end

function M.setup()
  local utils = require "lvim.utils"

  -- vim.g.bookmark_no_default_key_mappings = 0
  -- vim.g.bookmark_sign = ""
  -- vim.g.bookmark_save_per_working_dir = 0
  -- vim.g.bookmark_auto_save = 1
  -- vim.g.bookmark_manage_per_buffer = 0
  vim.g.bookmark_auto_save_file = utils.join_paths(get_cache_dir(), "bookmarks")

  lvim.builtin.which_key.mappings["m"] = { name = "+bookmarks" }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
