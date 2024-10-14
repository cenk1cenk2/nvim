-- https://github.com/harrisoncramer/gitlab.nvim
local M = {}

M.name = "harrisoncramer/gitlab.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "harrisoncramer/gitlab.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "sindrets/diffview.nvim",
          "stevearc/dressing.nvim",
          "nvim-tree/nvim-web-devicons",
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
          },
        })

        return c
      end)
    end,
    setup = function()
      ---@type Settings
      return {
        port = nil, -- The port of the Go server, which runs in the background, if omitted or `nil` the port will be chosen automatically
        log_path = vim.fn.stdpath("cache") .. "/gitlab.nvim.log", -- Log path for the Go server
        config_path = nil, -- Custom path for `.gitlab.nvim` file, please read the "Connecting to Gitlab" section
        debug = { go_request = false, go_response = false }, -- Which values to log
        attachment_dir = nil, -- The local directory for files (see the "summary" section)
        -- https://github.com/harrisoncramer/gitlab.nvim/blob/main/lua/gitlab/state.lua#L69
        keymaps = {
          popup = { -- The popup for comment creation, editing, and replying
            disable_all = false,
            next_field = "<Tab>",
            prev_field = "<S-Tab>",
            perform_action = "<C-s>",
            perform_linewise_action = "<C-l>",
            discard_changes = "<C-c>",
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
          severity = vim.diagnostic.severity.WARN,
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
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "t" }),
          function()
            require("gitlab").toggle_discussions()
          end,
          desc = "gitlab mr toggle discussions",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "T" }),
          function()
            require("gitlab").move_to_discussion_tree_from_diagnostic()
          end,
          desc = "gitlab mr move to discussion tree",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "o" }),
          function()
            require("gitlab").open_in_browser()
          end,
          desc = "gitlab mr open in browser",
        },
        {
          fn.wk_keystroke({ categories.GIT, "l", "p" }),
          group = "people",
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
          fn.wk_keystroke({ categories.GIT, "l", "P" }),
          function()
            require("gitlab").pipeline()
          end,
          desc = "gitlab mr pipeline",
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
          fn.wk_keystroke({ categories.GIT, "l", "P" }),
          function()
            require("gitlab").create_comment_suggestions()
          end,
          desc = "gitlab mr create suggestion",
          mode = { "v" },
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
