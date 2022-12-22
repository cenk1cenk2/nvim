-- https://github.com/tom-anders/telescope-vim-bookmarks.nvim
local M = {}

local extension_name = "telescope_vim_bookmarks"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "tom-anders/telescope-vim-bookmarks.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope vim_bookmarks" },
      }
    end,
    inject_to_configure = function()
      return {
        telescope = require("telescope"),
      }
    end,
    on_setup = function(config)
      local telescope = config.inject.telescope

      telescope.load_extension("vim_bookmarks")

      local bookmark_actions = telescope.extensions.vim_bookmarks.actions
      telescope.extensions.vim_bookmarks.all({
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      })

      telescope.extensions.vim_bookmarks.current_file({
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      })
    end,
    keymaps = {
      n = {
        ["mf"] = { ":Telescope vim_bookmarks all<CR>", { desc = "list all bookmarks" } },
        ["mF"] = { ":Telescope vim_bookmarks current_file<CR>", { desc = "list document bookmarks" } },
      },
    },
    wk = function(_, categories)
      return {
        [categories.BOOKMARKS] = {
          f = { ":Telescope vim_bookmarks all<CR>", "list all bookmarks" },
          F = { ":Telescope vim_bookmarks current_file<CR>", "list document bookmarks" },
        },
        [categories.FIND] = {
          m = { ":Telescope vim_bookmarks all<CR>", "list all bookmarks" },
          M = { ":Telescope vim_bookmarks current_file<CR>", "list document bookmarks" },
        },
      }
    end,
  })
end

return M
