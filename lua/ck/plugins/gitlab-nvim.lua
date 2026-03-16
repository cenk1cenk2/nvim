-- https://github.com/harrisoncramer/gitlab.nvim
local M = {}

M.name = "harrisoncramer/gitlab.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "harrisoncramer/gitlab.nvim",
        version = "*",
        dependencies = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "sindrets/diffview.nvim",
        },
        build = function()
          require("gitlab.server").build(true)
        end,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "gitlab",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.bottom, {
          {
            ft = "gitlab",
            title = "Gitlab",
            size = {
              height = function()
                if vim.o.lines < 60 then
                  return 0.2
                end

                return 20
              end,
            },
          },
        })

        return c
      end)
    end,
    setup = function(_, fn)
      ---@type Settings
      return {
        port = nil, -- The port of the Go server, which runs in the background, if omitted or `nil` the port will be chosen automatically
        log_path = join_paths(vim.fn.stdpath("cache"), "gitlab.nvim.log"), -- Log path for the Go server
        config_path = nil, -- Custom path for `.gitlab.nvim` file, please read the "Connecting to Gitlab" section
        debug = {
          go_request = require("ck.log"):to_nvim_level() == vim.log.levels.DEBUG,
          go_response = require("ck.log"):to_nvim_level() == vim.log.levels.DEBUG,
          request = require("ck.log"):to_nvim_level() == vim.log.levels.DEBUG,
          response = require("ck.log"):to_nvim_level() == vim.log.levels.DEBUG,
          gitlab_request = require("ck.log"):to_nvim_level() == vim.log.levels.DEBUG,
          gitlab_response = require("ck.log"):to_nvim_level() == vim.log.levels.DEBUG,
        }, -- Which values to log
        attachment_dir = nil, -- The local directory for files (see the "summary" section)
        -- https://github.com/harrisoncramer/gitlab.nvim/blob/main/lua/gitlab/state.lua#L69
        keymaps = {
          disable_all = false,
          help = "g?",
          global = {
            disable_all = true,
          },
          popup = {
            disable_all = false,
            next_field = "<C-n>",
            prev_field = "<C-p>",
            perform_action = "<C-s>",
            perform_linewise_action = "<C-l>",
            discard_changes = "<C-c><C-c>",
          },
          discussion_tree = {
            disable_all = false,
            add_emoji = fn.local_keystroke({ "sa" }),
            delete_emoji = fn.local_keystroke({ "sd" }),
            delete_comment = fn.local_keystroke({ "X" }),
            edit_comment = fn.local_keystroke({ "e" }),
            reply = fn.local_keystroke({ "r" }),
            toggle_resolved = fn.local_keystroke({ "R" }),
            jump_to_file = fn.local_keystroke({ "f" }),
            jump_to_reviewer = fn.local_keystroke({ "r" }),
            open_in_browser = fn.local_keystroke({ "o" }),
            copy_node_url = fn.local_keystroke({ "O" }),
            switch_view = fn.local_keystroke({ "w" }),
            toggle_tree_type = fn.local_keystroke({ "W" }),
            publish_draft = fn.local_keystroke({ "P" }),
            toggle_draft_mode = fn.local_keystroke({ "D" }),
            toggle_sort_method = "zs",
            toggle_node = "zo",
            toggle_all_discussions = "zR",
            toggle_resolved_discussions = "zT",
            toggle_unresolved_discussions = "zt",
            refresh_data = "<C-R>",
            print_node = "<localleader>p",
          },
          reviewer = {
            disable_all = true,
          },
        },
        info = { -- Show additional fields in the summary pane
          enabled = true,
          horizontal = true, -- Display metadata to the left of the summary rather than underneath
          fields = { -- The fields listed here will be displayed, in whatever order you choose
            "author",
            "created_at",
            "updated_at",
            "merge_status",
            "draft",
            "conflicts",
            "assignees",
            "reviewers",
            "branch",
            "pipeline",
          },
        },
        discussion_signs = {
          -- See :h sign_define for details about sign configuration.
          enabled = true,
          severity = "WARN",
          skip_resolved_discussion = false,
          text = nvim.ui.icons.ui.Comment,
          linehl = nil,
          texthl = nil,
          culhl = nil,
          numhl = nil,
          helper_signs = {
            -- For multiline comments the helper signs are used to indicate the whole context
            -- Priority of helper signs is lower than the main sign (-1).
            enabled = true,
            start = nvim.ui.icons.ui.ChevronShortUp,
            mid = nvim.ui.icons.borderchars[1],
            ["end"] = nvim.ui.icons.ui.ChevronShortDown,
          },
          virtual_text = false, -- Whether to show the comment text inline as floating virtual text
          priority = 100, -- Higher will override LSP warnings, etc
          icons = {
            comment = nvim.ui.icons.ui.Tab,
            range = nvim.ui.icons.ui.LineMiddle,
          },
        },
        pipeline = {
          created = "",
          pending = "",
          preparing = "",
          scheduled = "",
          running = "ﰌ",
          canceled = "ﰸ",
          skipped = "ﰸ",
          success = "✓",
          failed = "",
        },
        colors = {
          discussion_tree = {
            username = "Keyword",
            date = "Comment",
            chevron = "DiffviewNonText",
            directory = "Directory",
            directory_icon = "DiffviewFolderSign",
            file_name = "Normal",
          },
        },
        create_mr = {
          target = nil, -- Default branch to target when creating an MR
          template_file = nil, -- Default MR template in .gitlab/merge_request_templates
          delete_branch = true, -- Whether the source branch will be marked for deletion
          squash = false, -- Whether the commits will be marked for squashing
          title_input = { -- Default settings for MR title input window
            width = 40,
            border = nvim.ui.border,
          },
        },
      }
    end,
    on_setup = function(c)
      require("gitlab").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "l" }),
          group = "gitlab",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "d" }),
          function()
            require("gitlab").review()
          end,
          desc = "gitlab review",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "D" }),
          function()
            require("gitlab").choose_merge_request()
          end,
          desc = "gitlab mr to review",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "s" }),
          function()
            require("gitlab").summary()
          end,
          desc = "gitlab summary",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "A" }),
          function()
            require("gitlab").approve()
          end,
          desc = "gitlab mr approve",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "R" }),
          function()
            require("gitlab").revoke()
          end,
          desc = "gitlab mr revoke",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "c" }),
          function()
            require("gitlab").create_comment()
          end,
          desc = "gitlab mr create comment",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "f" }),
          function()
            require("gitlab").choose_merge_request()
          end,
          desc = "choose merge request",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "m" }),
          function()
            require("gitlab").create_mr({ delete_branch = true })
          end,
          desc = "gitlab create mr",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "M" }),
          function()
            require("gitlab").merge({ delete_branch = true })
          end,
          desc = "gitlab merge branch through mr",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "n" }),
          function()
            require("gitlab").create_note()
          end,
          desc = "gitlab mr create note",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "t" }),
          function()
            require("gitlab").move_to_discussion_tree_from_diagnostic()
          end,
          desc = "gitlab mr expand discussion",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "T" }),
          function()
            require("gitlab").toggle_discussions()
          end,
          desc = "gitlab mr toggle discussions",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "l" }),
          function()
            require("gitlab").toggle_draft_mode()
          end,
          desc = "gitlab toggle live/draft mode",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "P" }),
          function()
            require("gitlab").publish_all_drafts()
          end,
          desc = "gitlab publish drafts",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "o" }),
          function()
            require("gitlab").open_in_browser()
          end,
          desc = "gitlab mr open in browser",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "O" }),
          function()
            require("gitlab").pipeline()
          end,
          desc = "gitlab mr pipeline",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p" }),
          group = "people",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p", "l" }),
          function()
            require("gitlab").add_label()
          end,
          desc = "add label",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p", "L" }),
          function()
            require("gitlab").delete_label()
          end,
          desc = "remove label",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p", "a" }),
          function()
            require("gitlab").add_assignee()
          end,
          desc = "add assignee",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p", "A" }),
          function()
            require("gitlab").remove_assignee()
          end,
          desc = "remove assignee",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p", "r" }),
          function()
            require("gitlab").add_reviewer()
          end,
          desc = "add reviewer",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p", "R" }),
          function()
            require("gitlab").remove_reviewer()
          end,
          desc = "remove reviewer",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "Q" }),
          function()
            require("gitlab.server").restart()
          end,
          desc = "gitlab restart server",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "c" }),
          function()
            require("gitlab").create_multiline_comment()
          end,
          desc = "gitlab mr create comment",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "C" }),
          function()
            require("gitlab").create_comment_suggestion()
          end,
          desc = "gitlab mr create suggestion",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", categories.LOGS }),
          function()
            nvim.fn.toggle_log_view(join_paths(vim.fn.stdpath("cache"), "gitlab.nvim.log"))
          end,
          desc = "view log",
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").set_view_buffer({ "gitlab" }),
      }
    end,
  })
end

return M
