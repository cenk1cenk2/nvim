-- https://github.com/LintaoAmons/bookmarks.nvim
local M = {}

M.name = "LintaoAmons/bookmarks.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "LintaoAmons/bookmarks.nvim",
        dependencies = {
          { "kkharji/sqlite.lua" },
        },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function(_, fn)
      ---@type Bookmarks.Config
      return {
        backup = {
          enabled = false,
        },
        treeview = {
          keymap = {
            copy = fn.local_keystroke({ "y" }),
            create_list = fn.local_keystroke({ "A" }),
            cut = fn.local_keystroke({ "x" }),
            delete = fn.local_keystroke({ "d" }),
            ["goto"] = fn.local_keystroke({ "o" }),
            level_up = fn.local_keystroke({ "u" }),
            move_down = fn.local_keystroke({ "j" }),
            move_up = fn.local_keystroke({ "k" }),
            paste = fn.local_keystroke({ "p" }),
            quit = { "q", "<ESC>" },
            refresh = fn.local_keystroke({ "R" }),
            rename = fn.local_keystroke({ "r" }),
            reverse = fn.local_keystroke({ "s" }),
            set_active = fn.local_keystroke({ "m" }),
            set_root = fn.local_keystroke({ "." }),
            show_info = fn.local_keystroke({ "i" }),
            toggle = fn.local_keystroke({ "t" }),
          },
          window_split_dimension = 30,
        },
        signs = {
          -- Sign mark icon and color in the gutter
          mark = {
            icon = nvim.ui.icons.ui.BookMark,
            color = "",
            line_bg = "",
          },
          desc_format = function()
            return ""
          end,
        },
      }
    end,
    on_setup = function(c)
      require("bookmarks").setup(c)
    end,
    on_done = function()
      local project_name = require("ck.utils.fs").get_cwd()
      local Service = require("bookmarks.domain.service")
      local new_list = Service.create_list(project_name)
      Service.set_active_list(new_list.id)
      require("bookmarks.sign").safe_refresh_signs()
    end,
    keymaps = function(_, fn)
      ---@type KeymapMappings
      return {
        {
          fn.keystroke({ "m", "m" }),
          function()
            local Service = require("bookmarks.domain.service")
            local Sign = require("bookmarks.sign")

            Service.toggle_mark("")
            Sign.safe_refresh_signs()
          end,
          desc = "toggle bookmark",
        },

        {
          fn.keystroke({ "m", "X" }),
          function()
            local Repo = require("bookmarks.domain.repo")
            local Service = require("bookmarks.domain.service")
            local Sign = require("bookmarks.sign")

            local node = Repo.ensure_and_get_active_list()
            for _, bookmark in ipairs(node.children) do
              Service.delete_node(bookmark.id)
            end

            Sign.safe_refresh_signs()
          end,
          desc = "remove all bookmarks",
        },

        {
          fn.keystroke({ "m", "n" }),
          function()
            require("bookmarks").goto_next_list_bookmark()
          end,
          desc = "next bookmark",
        },

        {
          fn.keystroke({ "m", "p" }),
          function()
            require("bookmarks").goto_prev_list_bookmark()
          end,
          desc = "previous bookmark",
        },

        {
          fn.keystroke({ "m", "f" }),
          function()
            require("bookmarks").goto_bookmark()
          end,
          desc = "show bookmarks",
        },

        {
          fn.keystroke({ "m", "o" }),
          function()
            require("bookmarks").toggle_treeview()
          end,
          desc = "open treeview",
        },
      }
    end,
  })
end

return M
