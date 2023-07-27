-- https://github.com/tomasky/bookmarks.nvim
local M = {}

local extension_name = "bookmarks_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "tomasky/bookmarks.nvim",
      }
    end,
    setup = function()
      return {
        -- sign_priority = 8, --set bookmark sign priority to cover other sign
        save_file = join_paths(get_cache_dir(), "bookmarks"), -- bookmarks save file path
        keywords = {
          ["@t"] = lvim.ui.icons.misc.Watch, -- mark annotation startswith @t ,signs this icon as `Todo`
          ["@w"] = lvim.ui.icons.diagnostics.Warning, -- mark annotation startswith @w ,signs this icon as `Warn`
          ["@f"] = lvim.ui.icons.diagnostics.Trace, -- mark annotation startswith @f ,signs this icon as `Fix`
          ["@n"] = lvim.ui.icons.ui.Note, -- mark annotation startswith @n ,signs this icon as `Note`
        },
      }
    end,
    on_setup = function(config)
      require("bookmarks").setup(config.setup)
    end,
    on_done = function()
      require("telescope").load_extension("bookmarks")
    end,
    keymaps = {
      {
        { "n" },

        ["mm"] = {
          function()
            require("bookmarks").bookmark_toggle()
          end,
          { desc = "toggle bookmark" },
        },

        ["ma"] = {

          function()
            require("bookmarks").bookmark_ann()
          end,
          { desc = "bookmark annotation" },
        },

        ["md"] = {
          function()
            require("bookmarks").bookmark_clean()
          end,
          { desc = "bookmark clean" },
        },

        ["mn"] = {
          function()
            require("bookmarks").bookmark_next()
          end,
          { desc = "bookmark next" },
        },

        ["mp"] = {
          function()
            require("bookmarks").bookmark_prev()
          end,
          { desc = "bookmark previous" },
        },

        ["mf"] = {
          function()
            require("telescope").extensions.bookmarks.list({})
          end,
          { desc = "bookmark list" },
        },
      },
    },
  })
end

return M
