-- https://github.com/tomasky/bookmarks.nvim
local M = {}

M.name = "tomasky/bookmarks.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        -- using bookmark for telescope delete action
        -- "tomasky/bookmarks.nvim",
        "kevintraver/bookmarks.nvim",
        branch = "feature/telescope-delete-action",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        sign_priority = 10, --set bookmark sign priority to cover other sign
        save_file = join_paths(get_cache_dir(), "bookmarks"), -- bookmarks save file path
        linehl = false,
        signcolumn = true,
        numhl = false,
        signs = {
          add = { hl = "Bookmark", text = nvim.ui.icons.ui.BookMark, numhl = "BookMarksAddNr", linehl = "BookMarksAddLn" },
          ann = { hl = "Bookmark", text = nvim.ui.icons.ui.Flag, numhl = "BookMarksAnnNr", linehl = "BookMarksAnnLn" },
        },
      }
    end,
    on_setup = function(c)
      require("bookmarks").setup(c)
    end,
    on_done = function()
      require("telescope").load_extension("bookmarks")
    end,
    keymaps = function(_, fn)
      ---@type WKMappings
      return {
        {
          fn.keystroke({ "m", "m" }),
          function()
            require("bookmarks").bookmark_toggle()
          end,
          desc = "toggle bookmark",
        },

        {
          fn.keystroke({ "m", "n" }),
          function()
            require("bookmarks").bookmark_next()
          end,
          desc = "next bookmark",
        },

        {
          fn.keystroke({ "m", "p" }),
          function()
            require("bookmarks").bookmark_prev()
          end,
          desc = "previous bookmark",
        },

        {
          fn.keystroke({ "m", "f" }),
          function()
            require("telescope").extensions.bookmarks.list()
          end,
          desc = "show bookmarks",
        },

        {
          fn.keystroke({ "m", "q" }),
          function()
            require("bookmarks").bookmark_list()
          end,
          desc = "bookmarks to quickfix",
        },

        {
          fn.keystroke({ "m", "x" }),
          function()
            require("bookmarks").bookmark_clean()
          end,
          desc = "clean bookmarks in current buffer",
        },

        {
          fn.keystroke({ "m", "X" }),
          function()
            require("bookmarks").bookmark_clean()
          end,
          desc = "clean bookmarks",
        },
      }
    end,
  })
end

return M
