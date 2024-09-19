-- https://github.com/epwalsh/obsidian.nvim
local M = {}

M.name = "epwalsh/obsidian.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "epwalsh/obsidian.nvim",
        event = {
          {
            event = { "BufReadPre", "BufNewFile" },
            pattern = { ("%s/notes/**.md"):format(vim.fn.expand("~")) },
          },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = {
          "ObsidianCheck",
          "ObsidianToggleCheckbox",
          "ObsidianToday",
          "ObsidianYesterday",
          "ObsidianTomorrow",
          "ObsidianDailies",
          "ObsidianNew",
          "ObsidianOpen",
          "ObsidianBacklinks",
          "ObsidianSearch",
          "ObsidianTags",
          "ObsidianTemplate",
          "ObsidianNewFromTemplate",
          "ObsidianQuickSwitch",
          "ObsidianLinkNew",
          "ObsidianLink",
          "ObsidianLinks",
          "ObsidianFollowLink",
          "ObsidianWorkspace",
          "ObsidianRename",
          "ObsidianPasteImg",
          "ObsidianExtractNote",
          "ObsidianDebug",
          "ObsidianTOC",
        },
      }
    end,
    setup = function()
      ---@type obsidian.config.ClientOpts
      return {
        workspaces = {
          {
            name = "notes",
            path = "~/notes",
          },
        },
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

        note_id_func = function(title)
          return title or os.date("%Y%m%dT%H%M%S")
        end,

        preferred_link_style = "wiki",

        new_notes_location = "current_dir",

        completion = {
          nvim_cmp = true,
          min_chars = 2,
        },

        -- Optional, customize how wiki links are formatted. You can set this to one of:
        --  * "use_alias_only", e.g. '[[Foo Bar]]'
        --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
        --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
        --  * "use_path_only", e.g. '[[foo-bar.md]]'
        wiki_link_func = function(opts)
          return require("obsidian.util").wiki_link_id_prefix(opts)
        end,

        -- Optional, customize how markdown links are formatted.
        markdown_link_func = function(opts)
          return require("obsidian.util").markdown_link(opts)
        end,

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
          -- ["gc"] = {
          --   action = function()
          --     return require("obsidian").util.toggle_checkbox()
          --   end,
          --   opts = { buffer = true },
          -- },
          -- Smart action depending on context, either follow link or toggle checkbox.
          ["<C-CR>"] = {
            action = function()
              return require("obsidian").util.smart_action()
            end,
            opts = { buffer = true, expr = true },
          },
        },

        templates = {
          subdir = "Templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          -- A map for custom variables, the key should be the variable and the value a function
          substitutions = {},
        },

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        follow_url_func = function(url)
          vim.ui.open(url)
        end,

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        follow_img_func = function(img)
          -- Open the URL in the default web browser.
          vim.ui.open(img)
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

        picker = {
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
          name = "telescope.nvim",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          note_mappings = {
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
          tag_mappings = {
            -- Add tag(s) to current note.
            tag_note = "<C-x>",
            -- Insert a tag at the current location.
            insert_tag = "<C-l>",
          },
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
          checkboxes = {
            -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            -- [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            -- ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
            -- ["!"] = { char = "", hl_group = "ObsidianImportant" },
            -- Replace the above with this if you don't have a patched font:
            -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
            -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

            -- You can also add more custom ones...
          },
        },
      }
    end,
    on_setup = function(c)
      require("obsidian").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.NOTES, "p" }),
          function()
            vim.cmd([[ObsidianQuickSwitch]])
          end,
          desc = "find notes",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "P" }),
          function()
            vim.cmd([[ObsidianTOC]])
          end,
          desc = "find in toc",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "f" }),
          function()
            vim.cmd([[ObsidianSearch]])
          end,
          desc = "search",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "F" }),
          function()
            vim.cmd([[ObsidianTags]])
          end,
          desc = "search with tags",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d" }),
          group = "day",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "w" }),
          function()
            M.note_from_template("Calendar/Week", os.date("%Y-%W"), "Daily.md")
          end,
          desc = "week",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "q" }),
          function()
            M.note_from_template("Todo", os.date("%Y%m%dT%H%M%S"), "Draft.md")
          end,
          desc = "quick todo",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "t" }),
          function()
            vim.cmd([[ObsidianToday]])
          end,
          desc = "today",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "n" }),
          function()
            vim.cmd([[ObsidianTomorrow]])
          end,
          desc = "tomorrow",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "p" }),
          function()
            vim.cmd([[ObsidianYesterday]])
          end,
          desc = "yesterday",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "f" }),
          function()
            vim.cmd([[ObsidianDailies]])
          end,
          desc = "find",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "o" }),
          function()
            vim.cmd([[ObsidianOpen]])
          end,
          desc = "open in gui",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "l" }),
          function()
            vim.cmd([[ObsidianLinks]])
          end,
          desc = "links",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "L" }),
          function()
            vim.cmd([[ObsidianBacklinks]])
          end,
          desc = "backlinks",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "l" }),
          function()
            vim.cmd([[ObsidianLinkNew]])
          end,
          desc = "link this with new",
          mode = { "v" },
        },

        {
          fn.wk_keystroke({ categories.NOTES, "n" }),
          function()
            vim.cmd([[ObsidianNew]])
          end,
          desc = "create new note",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "n" }),
          function()
            vim.cmd([[ObsidianExtractNote]])
          end,
          desc = "extract note",
          mode = { "v" },
        },

        {
          fn.wk_keystroke({ categories.NOTES, "w" }),
          function()
            vim.cmd([[ObsidianWorkspace]])
          end,
          desc = "select workspace",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "P" }),
          function()
            vim.cmd(("ObsidianPasteImg %s"):format(join_paths(require("ck.utils.fs").get_project_buffer_filepath(), "assets/")))
          end,
          desc = "paste image from clipboard",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "t" }),
          function()
            vim.cmd([[ObsidianNewFromTemplate]])
          end,
          desc = "new from template",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "T" }),
          function()
            vim.cmd([[ObsidianTemplate]])
          end,
          desc = "paste from template",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "m" }),
          function()
            vim.cmd([[ObsidianRename]])
          end,
          desc = "rename note",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "M" }),
          function()
            vim.cmd([[ObsidianRename --dry-run]])
          end,
          desc = "rename note [dry-run]",
        },
      }
    end,
  })
end

function M.note_from_template(root, title, template)
  local client = require("obsidian"):get_client()
  local file = ("%s/%s.md"):format(root, title)
  local matches = client:resolve_note(file)

  if matches then
    require("ck.log"):info("Opening note: %s", file)
    vim.cmd(([[ObsidianQuickSwitch %s]]):format(file))
  else
    vim.cmd(([[ObsidianNew %s]]):format(file))

    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    if #lines == 2 and lines[1] == ("# %s"):format(title) then
      require("ck.log"):info("Templating note: %s -> %s", file, template)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, {})
      vim.cmd(([[ObsidianTemplate %s]]):format(template))
    end
  end
end

return M
