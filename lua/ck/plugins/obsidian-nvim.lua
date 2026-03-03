-- https://github.com/obsidian-nvim/obsidian.nvim
local M = {}

M.name = "obsidian-nvim/obsidian.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "obsidian-nvim/obsidian.nvim",
        event = {
          {
            event = { "BufReadPre", "BufNewFile" },
            pattern = { ("%s/notes/**.md"):format(vim.fn.expand("~")) },
          },
        },
        dependencies = {},
        cmd = {
          "Obsidian",
        },
      }
    end,
    setup = function()
      ---@type obsidian.config
      return {
        workspaces = {
          {
            name = "notes",
            path = "~/notes",
          },
        },
        log_level = vim.log.levels.INFO,
        legacy_commands = false,

        daily_notes = {
          folder = "Calendar/Day",
          date_format = "YYYY-MM-DD",
          alias_format = "MMMM D, YYYY",
          template = "Daily.md",
        },

        frontmatter = {
          enabled = false,
        },

        note_id_func = function(title)
          return title or os.date("%Y%m%dT%H%M%S")
        end,

        preferred_link_style = "markdown",

        new_notes_location = "current_dir",

        note_path_func = function(spec)
          return join_paths(require("ck.utils.fs").get_buffer_dirpath(), ("%s.md"):format(tostring(spec.id)))
        end,

        completion = {
          min_chars = 2,
        },

        wiki_link_func = function(opts)
          return require("obsidian.builtin").wiki_link_id_prefix(opts)
        end,

        markdown_link_func = function(opts)
          return require("obsidian.builtin").markdown_link(opts)
        end,

        templates = {
          folder = "Templates",
          date_format = "YYYY-MM-DD",
          time_format = "HH:mm",
          substitutions = {},
        },

        picker = {
          name = "telescope.nvim",
          note_mappings = {
            new = "<C-x>",
            insert_link = "<C-l>",
          },
          tag_mappings = {
            tag_note = "<C-x>",
            insert_tag = "<C-l>",
          },
        },

        search = {
          sort_by = "modified",
          sort_reversed = true,
        },

        open_notes_in = "current",

        attachments = {
          folder = "",
        },

        checkbox = {
          order = { " ", "x" },
        },

        ui = {
          enable = false,
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
            require("obsidian.commands.quick_switch")({})
          end,
          desc = "find notes",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "s" }),
          function()
            require("obsidian.commands.toc")()
          end,
          desc = "find in toc",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "f" }),
          function()
            require("obsidian.commands.search")({})
          end,
          desc = "search",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "F" }),
          function()
            require("obsidian.commands.tags")({})
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
          fn.wk_keystroke({ categories.NOTES, "C" }),
          function()
            M.note_from_template("Todo", os.date("%Y%m%dT%H%M%S"), "Draft.md")
          end,
          desc = "quick todo",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "t" }),
          function()
            require("obsidian.commands.today")({ args = "" })
          end,
          desc = "today",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "n" }),
          function()
            require("obsidian.commands.tomorrow")({ args = "" })
          end,
          desc = "tomorrow",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "p" }),
          function()
            require("obsidian.commands.yesterday")({ args = "" })
          end,
          desc = "yesterday",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "d", "f" }),
          function()
            require("obsidian.commands.dailies")({ args = "" })
          end,
          desc = "find",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "o" }),
          function()
            require("obsidian.commands.open")()
          end,
          desc = "open in gui",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "l" }),
          function()
            require("obsidian.commands.links")()
          end,
          desc = "links",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "L" }),
          function()
            require("obsidian.commands.backlinks")()
          end,
          desc = "backlinks",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "l" }),
          function()
            require("obsidian.commands.link_new")({})
          end,
          desc = "link this with new",
          mode = { "v" },
        },

        {
          fn.wk_keystroke({ categories.NOTES, "c" }),
          function()
            require("obsidian.commands.new")({ args = "" })
          end,
          desc = "create new note",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "c" }),
          function()
            require("obsidian.commands.extract_note")({})
          end,
          desc = "extract note",
          mode = { "v" },
        },

        {
          fn.wk_keystroke({ categories.NOTES, "W" }),
          function()
            require("obsidian.commands.workspace")({})
          end,
          desc = "select workspace",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "P" }),
          function()
            require("obsidian.commands.paste_img")({
              args = join_paths(require("ck.utils.fs").get_project_buffer_dirpath(), "assets/", ("%s.png"):format(os.date("%Y%m%dT%H%M%S"))),
            })
          end,
          desc = "paste image from clipboard",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "t" }),
          function()
            require("obsidian.commands.new_from_template")({ fargs = {} })
          end,
          desc = "new from template",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "T" }),
          function()
            require("obsidian.commands.template")({})
          end,
          desc = "paste from template",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "R" }),
          function()
            require("obsidian.commands.rename")({})
          end,
          desc = "rename note",
        },

        {
          fn.wk_keystroke({ categories.NOTES, "M" }),
          function()
            require("obsidian.commands.rename")({ args = { dry_run = true } })
          end,
          desc = "rename note [dry-run]",
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").init_with({ "FileType" }, { "markdown" }, function(event)
          return {
            keymaps = function(_, fn)
              ---@type KeymapMappings
              return {
                {
                  "gf",
                  function()
                    return require("obsidian.api").follow_link()
                  end,
                  desc = "go to file",
                  buffer = event.buf,
                  expr = true,
                },
                {
                  fn.local_keystroke({ "t" }),
                  function()
                    return require("obsidian.api").smart_action()
                  end,
                  desc = "obsidian smart action",
                  buffer = event.buf,
                },
                {
                  fn.local_keystroke({ "c" }),
                  function()
                    return require("obsidian.api").toggle_checkbox()
                  end,
                  desc = "obsidian toggle checkbox",
                  buffer = event.buf,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

function M.note_from_template(root, title, template)
  local search = require("obsidian.search")
  local api = require("obsidian.api")
  local file = ("%s/%s.md"):format(root, title)
  local notes = search.resolve_note(file)

  if #notes > 0 then
    require("ck.log"):info("Opening note: %s", file)
    api.open_note(tostring(notes[1].path))

    return
  end

  require("ck.log"):info("Creating note: %s from %s", file, template)

  local Path = require("obsidian.path")
  local Note = require("obsidian.note")
  local Template = require("obsidian.templates")

  local note_path = Path.new(Obsidian.dir) / file
  assert(note_path:parent()):mkdir({ parents = true, exist_ok = true })

  local note = Note.new(title, {}, {}, note_path, title)
  Template.clone_template({
    type = "clone_template",
    template_name = template,
    destination_path = note_path,
    templates_dir = api.templates_dir(),
    partial_note = note,
  })
  note:open({ sync = true })
end

return M
