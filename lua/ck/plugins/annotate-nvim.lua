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
        c.sources.per_filetype.annotate = function()
          return { "buffer", "path" }
        end

        return c
      end)
    end,
    setup = function()
      return {
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
          fn.wk_keystroke({ categories.GIT, "m" }),
          group = "annotate",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "c" }),
          function()
            require("annotate").add()
          end,
          desc = "annotate add",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "b" }),
          function()
            require("annotate").add_file()
          end,
          desc = "annotate file",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "e" }),
          function()
            require("annotate").edit()
          end,
          desc = "annotate edit",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "x" }),
          function()
            require("annotate").delete()
          end,
          desc = "annotate delete",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "j" }),
          function()
            require("annotate").next()
          end,
          desc = "annotate next",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "k" }),
          function()
            require("annotate").prev()
          end,
          desc = "annotate previous",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "f" }),
          function()
            require("annotate").pick()
          end,
          desc = "annotate choose",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "q" }),
          function()
            require("annotate").quickfix()
          end,
          desc = "annotate set quickfix",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "s" }),
          function()
            require("annotate").preview()
          end,
          desc = "annotate summary",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "P" }),
          function()
            require("annotate").export()
          end,
          desc = "annotate export",
        },
        {
          fn.wk_keystroke({ categories.GIT, "m", "S" }),
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
          fn.wk_keystroke({ categories.GIT, "m", "X" }),
          function()
            require("annotate").clear()
          end,
          desc = "annotate archive and clear",
        },
      }
    end,
  })
end

return M
