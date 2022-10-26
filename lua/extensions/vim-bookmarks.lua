-- https://github.com/MattesGroeger/vim-bookmarks
local M = {}

local extension_name = "vim_bookmarks"
local utils = require "lvim.utils"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "MattesGroeger/vim-bookmarks",
        branch = "fix/118",
        config = function()
          require("utils.setup").packer_config "vim_bookmarks"
        end,
        disable = not config.active,
      }
    end,
    legacy_setup = {
      -- bookmark_no_default_key_mappings = 0
      bookmark_annotation_sign = "",
      bookmark_sign = "⚑",
      -- bookmark_save_per_working_dir = 0
      -- bookmark_auto_save = 1
      -- bookmark_manage_per_buffer = 0
      bookmark_auto_save_file = join_paths(get_cache_dir(), "bookmarks"),
    },
  })
end

return M
