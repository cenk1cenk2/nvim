-- https://github.com/cenk1cenk2/annotate.nvim
local M = {}

M.name = "cenk1cenk2/annotate.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/annotate.nvim",
        cmd = { "Annotate" },
        dependencies = {
          "folke/snacks.nvim",
        },
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.blink-cmp").name, function(c)
        c.sources.providers.annotate = {
          name = "annotate",
          module = "annotate.blink",
        }
        c.sources.per_filetype.annotate = function()
          return {
            "snippets",
            "path",
            "buffer",
            "ripgrep",
            "annotate",
          }
        end

        return c
      end)
    end,
    setup = function()
      local icons = {
        apply = nvim.ui.icons.ui.Pencil,
        rewrite = nvim.ui.icons.ui.Code,
        consider = nvim.ui.icons.ui.Lightbulb,
        discuss = nvim.ui.icons.diagnostics.Question,
        report = nvim.ui.icons.ui.Search,
        keep = nvim.ui.icons.ui.Check,
        context = nvim.ui.icons.ui.Note,
      }

      return {
        types = vim.tbl_map(function(type)
          return vim.tbl_extend("force", type, { icon = icons[type.key] or type.icon })
        end, require("annotate.config").options.types),
        archive_days = 14,
        confirm_delete = false,
        store = {
          per_branch = true,
        },
        picker = {
          force = {
            delete = true,
            delete_all = true,
            restore_clear = true,
            split = true,
          },
        },
        export = {
          prompt = "@hyprpilot-skills:skill://code-annotations/SKILL.md Work through these review notes on the repository. Each section below groups one kind of note, and its line under Description says what I expect for that kind. Re-read the code at each location before acting, since lines may have moved since I wrote the note, and do what the note's type asks. Bring back anything that needs me one at a time, each with its file and line and a one-line summary of the code there. Report back item by item when you finish.",
          clipboard_message = "@hyprpilot-skills:skill://code-annotations/SKILL.md Work through my review notes in the attached file.",
        },
        external = {
          legend = true,
          legend_prompt = function(default)
            return "`@hyprpilot-skills:skill://code-annotations/SKILL.md` " .. default
          end,
        },
        input = {
          width = nvim.ui.dimensions.float.sm,
          height = nvim.ui.dimensions.float.xs,
          border = nvim.ui.border,
        },
      }
    end,
    on_setup = function(c)
      require("annotate").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.MARK }),
          group = "mark",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.MARK, "l" }),
          function()
            require("annotate")
            require("annotate.marks").refresh()
          end,
          desc = "annotate load",
        },
        {
          fn.wk_keystroke({ categories.MARK, "c" }),
          function()
            require("annotate").add()
          end,
          desc = "annotate add",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.MARK, "b" }),
          function()
            require("annotate").add_file()
          end,
          desc = "annotate buffer",
        },
        {
          fn.wk_keystroke({ categories.MARK, "B" }),
          function()
            require("annotate").add_file_with_type()
          end,
          desc = "annotate buffer with type",
        },
        {
          fn.wk_keystroke({ categories.MARK, "m" }),
          function()
            require("annotate").publish()
          end,
          desc = "annotate stage drafts on the merge request",
        },
        {
          fn.wk_keystroke({ categories.MARK, "M" }),
          function()
            require("annotate").publish({ publish = true })
          end,
          desc = "annotate submit review",
        },
        {
          fn.wk_keystroke({ categories.MARK, "n" }),
          function()
            require("annotate").add_repository()
          end,
          desc = "annotate repository",
        },
        {
          fn.wk_keystroke({ categories.MARK, "N" }),
          function()
            require("annotate").add_repository_with_type()
          end,
          desc = "annotate repository with type",
        },
        {
          fn.wk_keystroke({ categories.MARK, "C" }),
          function()
            require("annotate").add_with_type()
          end,
          desc = "annotate add with type",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.MARK, "r" }),
          function()
            require("annotate").restore()
          end,
          desc = "annotate restore archive",
        },
        {
          fn.wk_keystroke({ categories.MARK, "R" }),
          function()
            require("annotate").clear_archive({ force = true })
          end,
          desc = "annotate clear archives",
        },
        {
          fn.wk_keystroke({ categories.MARK, "o" }),
          function()
            require("annotate").show()
          end,
          desc = "annotate show",
        },
        {
          fn.wk_keystroke({ categories.MARK, "e" }),
          function()
            require("annotate").edit()
          end,
          desc = "annotate edit",
        },
        {
          fn.wk_keystroke({ categories.MARK, "x" }),
          function()
            require("annotate").delete({ force = true })
          end,
          desc = "annotate delete",
        },
        {
          fn.wk_keystroke({ categories.MARK, "j" }),
          function()
            require("annotate").next()
          end,
          desc = "annotate next",
        },
        {
          fn.wk_keystroke({ categories.MARK, "k" }),
          function()
            require("annotate").prev()
          end,
          desc = "annotate previous",
        },
        {
          fn.wk_keystroke({ categories.MARK, "f" }),
          function()
            require("annotate").pick()
          end,
          desc = "annotate choose",
        },
        {
          fn.wk_keystroke({ categories.MARK, "F" }),
          function()
            require("annotate").pick({ all = true })
          end,
          desc = "annotate choose from all branches",
        },
        {
          fn.wk_keystroke({ categories.MARK, "q" }),
          function()
            require("annotate").quickfix()
          end,
          desc = "annotate set quickfix",
        },
        {
          fn.wk_keystroke({ categories.MARK, "p" }),
          function()
            require("annotate").preview()
          end,
          desc = "annotate summary",
        },
        {
          fn.wk_keystroke({ categories.MARK, "P" }),
          function()
            require("annotate").export()
          end,
          desc = "annotate export",
        },
        {
          fn.wk_keystroke({ categories.MARK, "S" }),
          function()
            require("annotate").export({
              to = function(markdown)
                require("sidekick.cli").send({ msg = markdown })
              end,
            })
          end,
          desc = "annotate send to sidekick",
        },
        {
          fn.wk_keystroke({ categories.MARK, "X" }),
          function()
            require("annotate").clear({ force = true })
          end,
          desc = "annotate archive and clear",
        },
      }
    end,
    toggles = function(_, categories, fn)
      ---@type WKToggleMappings
      return {
        {
          fn.wk_keystroke({ categories.MARK, "L" }),
          function()
            return require("snacks.toggle").new({
              name = "annotate type descriptions on the merge request",
              get = function()
                return require("annotate.config").options.external.legend
              end,
              set = function(state)
                require("annotate.config").options.external.legend = state
              end,
            })
          end,
          desc = "annotate type descriptions on the merge request",
        },
      }
    end,
  })
end

return M
