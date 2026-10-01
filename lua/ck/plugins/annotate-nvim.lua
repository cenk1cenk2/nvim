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
          local origin = vim.b.annotate_origin
          local sources = origin and vim.api.nvim_buf_is_valid(origin) and c.sources.per_filetype[vim.bo[origin].filetype]
          if type(sources) == "function" then
            sources = sources()
          end

          return vim.list_extend(vim.deepcopy(sources or { inherit_defaults = true }), { "annotate" })
        end

        return c
      end)
    end,
    setup = function()
      local icons = {
        issue = nvim.ui.icons.ui.Pencil,
        general = nvim.ui.icons.git.Repo,
        praise = nvim.ui.icons.ui.Check,
        suggestion = nvim.ui.icons.ui.Lightbulb,
        bug = nvim.ui.icons.ui.Bug,
        question = nvim.ui.icons.diagnostics.Question,
        context = nvim.ui.icons.ui.Note,
      }

      return {
        types = vim.tbl_map(function(type)
          return vim.tbl_extend("force", type, { icon = icons[type.key] or type.icon })
        end, require("annotate.config").options.types),
        archive_days = 14,
        confirm_delete = false,
        picker = {
          force = {
            delete = true,
            delete_all = true,
            restore_clear = true,
          },
        },
        export = {
          prompt = "@hyprpilot-skills:skill://code-annotations/SKILL.md Work through these review notes on the repository. Each section below groups one kind of note, and its line under Description says what I expect for that kind. Re-read the code at each location before acting, since lines may have moved since I wrote the note, and do what the note's type asks. Bring back anything that needs me one at a time, each with its file and line and a one-line summary of the code there. Report back item by item when you finish.",
          clipboard_message = "@hyprpilot-skills:skill://code-annotations/SKILL.md Work through my review notes in the attached file.",
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
          desc = "annotate file",
        },
        {
          fn.wk_keystroke({ categories.MARK, "n" }),
          function()
            require("annotate").add_repository()
          end,
          desc = "annotate repository",
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
          fn.wk_keystroke({ categories.MARK, "s" }),
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
  })
end

return M
