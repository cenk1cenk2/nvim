-- https://github.com/tom-anders/telescope-vim-bookmarks.nvim
local M = {}

local extension_name = "telescope_vim_bookmarks"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "tom-anders/telescope-vim-bookmarks.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
          require("utils.setup").packer_config "telescope_vim_bookmarks"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
      }
    end,
    on_setup = function(config)
      local telescope = config.inject.telescope

      telescope.load_extension "vim_bookmarks"

      local bookmark_actions = telescope.extensions.vim_bookmarks.actions
      telescope.extensions.vim_bookmarks.all {
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      }

      telescope.extensions.vim_bookmarks.current_file {
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      }
    end,
  })
end

return M