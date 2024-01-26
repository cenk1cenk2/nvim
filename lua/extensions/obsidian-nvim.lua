-- https://github.com/epwalsh/obsidian.nvim
local M = {}

local extension_name = "epwalsh/obsidian.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "epwalsh/obsidian.nvim",
        event = {
          "BufReadPre " .. vim.fn.expand("~") .. "/notes/**.md",
          "BufNewFile " .. vim.fn.expand("~") .. "/notes/**.md",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = {
          "ObsidianFollowLink",
          "ObsidianBacklinks",
          "ObsidianToday",
          "ObsidianYesterday",
          "ObsidianTomorrow",
          "ObsidianTemplate",
          "ObsidianSearch",
          "ObsidianLink",
          "ObsidianLinkNew",
          "ObsidianWorkspace",
          "ObsidianPasteImg",
          "ObsidianRename",
        },
      }
    end,
    setup = function()
      return {
        workspaces = {
          {
            name = "notes",
            path = "~/notes",
          },
        },
        -- Alternatively - and for backwards compatibility - you can set 'dir' to a single path instead of
        -- 'workspaces'. For example:
        -- dir = "~/vaults/work",

        -- Optional, set to true to use the current directory as a vault; otherwise
        -- the first workspace is opened by default.
        detect_cwd = true,

        -- Optional, set the log level for obsidian.nvim. This is an integer corresponding to one of the log
        -- levels defined by "vim.log.levels.*".
        log_level = vim.log.levels.INFO,

        daily_notes = {
          -- Optional, if you keep daily notes in a separate directory.
          folder = "Calendar/Day",
          -- Optional, if you want to change the date format for the ID of daily notes.
          date_format = "%Y-%m-%d",
          -- Optional, if you want to change the date format of the default alias of daily notes.
          alias_format = "%B %-d, %Y",
          -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
          template = "Daily.md",
        },

        disable_frontmatter = true,
        note_frontmatter_func = function(note)
          -- This is equivalent to the default frontmatter function.
          local out = {
            id = note.id,
            aliases = note.aliases,
            tags = note.tags,
          }
          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,

        -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
        completion = {
          -- Set to false to disable completion.
          nvim_cmp = true,

          -- Trigger completion at 2 chars.
          min_chars = 2,

          -- Where to put new notes created from completion. Valid options are
          --  * "current_dir" - put new notes in same directory as the current buffer.
          --  * "notes_subdir" - put new notes in the default notes subdirectory.
          new_notes_location = "current_dir",

          -- Control how wiki links are completed with these (mutually exclusive) options:
          --
          -- 1. Whether to add the note ID during completion.
          -- E.g. "[[Foo" completes to "[[foo|Foo]]" assuming "foo" is the ID of the note.
          -- Mutually exclusive with 'prepend_note_path' and 'use_path_only'.
          prepend_note_id = true,
          -- 2. Whether to add the note path during completion.
          -- E.g. "[[Foo" completes to "[[notes/foo|Foo]]" assuming "notes/foo.md" is the path of the note.
          -- Mutually exclusive with 'prepend_note_id' and 'use_path_only'.
          prepend_note_path = false,
          -- 3. Whether to only use paths during completion.
          -- E.g. "[[Foo" completes to "[[notes/foo]]" assuming "notes/foo.md" is the path of the note.
          -- Mutually exclusive with 'prepend_note_id' and 'prepend_note_path'.
          use_path_only = false,
        },

        -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
        -- way then set 'mappings = {}'.
        mappings = {
          -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
          ["gf"] = {
            action = function()
              return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
          -- Toggle check-boxes.
          ["gc"] = {
            action = function()
              return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true },
          },
        },

        templates = {
          subdir = "Templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          -- A map for custom variables, the key should be the variable and the value a function
          substitutions = {},
        },

        -- Optional, customize the backlinks interface.
        backlinks = {
          -- The default height of the backlinks pane.
          height = 10,
          -- Whether or not to wrap lines.
          wrap = true,
        },

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        follow_url_func = function(url)
          -- Open the URL in the default web browser.
          -- vim.fn.jobstart({ "open", url }) -- Mac OS
          vim.fn.jobstart({ "xdg-open", url }) -- linux
        end,

        -- Optional, set to true if you use the Obsidian Advanced URI plugin.
        -- https://github.com/Vinzent03/obsidian-advanced-uri
        use_advanced_uri = false,

        -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
        open_app_foreground = true,

        -- Optional, by default commands like `:ObsidianSearch` will attempt to use
        -- telescope.nvim, fzf-lua, fzf.vim, or mini.pick (in that order), and use the
        -- first one they find. You can set this option to tell obsidian.nvim to always use this
        -- finder.
        finder = "telescope.nvim",

        -- Optional, configure key mappings for the finder. These are the defaults.
        -- If you don't want to set any mappings this way then set
        finder_mappings = {
          -- Create a new note from your query with `:ObsidianSearch` and `:ObsidianQuickSwitch`.
          -- Currently only telescope supports this.
          new = "<C-x>",
        },

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,

        -- Optional, determines how certain commands open notes. The valid options are:
        -- 1. "current" (the default) - to always open in the current window
        -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
        -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
        open_notes_in = "current",

        -- Specify how to handle attachments.
        attachments = {
          -- The default folder to place images in via `:ObsidianPasteImg`.
          -- If this is a relative path it will be interpreted as relative to the vault root.
          -- You can always override this per image by passing a full path to the command instead of just a filename.
          img_folder = "assets", -- This is the default
        },

        -- Optional, configure additional syntax highlighting / extmarks.
        -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
        ui = {
          enable = false, -- set to false to disable all additional syntax features
        },
      }
    end,
    on_setup = function(config)
      require("obsidian").setup(config.setup)
    end,
  })
end

return M
