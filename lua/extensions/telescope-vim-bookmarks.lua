-- https://github.com/reaz1995/telescope-vim-bookmarks.nvim
local M = {}

local extension_name = "telescope_vim_bookmarks"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "reaz1995/telescope-vim-bookmarks.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
      }
    end,
    on_setup = function()
      local telescope = require("telescope")

      telescope.load_extension("vim_bookmarks")

      local bookmark_actions = telescope.extensions.vim_bookmarks.actions
      telescope.extensions.vim_bookmarks.all({
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      })
    end,
    -- keymaps = {
    --   {
    --     { "n" },
    --
    --     ["mf"] = {
    --       function()
    --         require("telescope").extensions.vim_bookmarks.all()
    --       end,
    --       { desc = "list all bookmarks" },
    --     },
    --     ["mF"] = {
    --       function()
    --         require("telescope").extensions.vim_bookmarks.current_file()
    --       end,
    --       { desc = "list document bookmarks" },
    --     },
    --   },
    -- },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.FIND, "m" }),
          function()
            require("telescope").extensions.vim_bookmarks.all()
          end,
          desc = "list all bookmarks",
        },
        {
          fn.wk_keystroke({ categories.FIND, "M" }),
          function()
            require("telescope").extensions.vim_bookmarks.current_file()
          end,
          desc = "list document bookmarks",
        },
      }
    end,
  })
end

return M
