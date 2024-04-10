-- https://github.com/andythigpen/nvim-coverage
local M = {}

local extension_name = "andythigpen/nvim-coverage"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "andythigpen/nvim-coverage",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
      }
    end,
    setup = function()
      return {
        auto_reload = true,
        commands = true, -- create commands
        load_coverage_cb = function(ftype)
          require("lvim.core.log"):info(("Loaded test coverage: %s"):format(ftype))
        end,
        highlights = {
          -- customize highlight groups created by the plugin
          covered = { fg = lvim.ui.colors.green[300] }, -- supports style, fg, bg, sp (see :h highlight-gui)
          partial = { fg = lvim.ui.colors.yellow[300] },
          uncovered = { fg = lvim.ui.colors.red[300] },
        },
        signs = {
          -- use your own highlight groups or text markers
          covered = { hl = "CoverageCovered", text = lvim.ui.icons.ui.TriangleShortArrowRight },
          partial = { hl = "CoveragePartial", text = lvim.ui.icons.ui.TriangleShortArrowRight },
          uncovered = { hl = "CoverageUncovered", text = lvim.ui.icons.ui.TriangleShortArrowRight },
        },
        summary = {
          -- customize the summary pop-up
          min_coverage = 50.0, -- minimum coverage threshold (used for highlighting)
        },
        lang = {
          -- customize language specific settings
        },
      }
    end,
    on_setup = function(config)
      require("coverage").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.TESTS] = {
          ["c"] = {
            name = "coverage",

            ["c"] = {
              function()
                require("coverage").clear()
              end,
              "clear coverage",
            },

            ["l"] = {
              function()
                require("coverage").load(true)
              end,
              "load coverage file",
            },

            ["t"] = {
              function()
                require("coverage").toggle()
              end,
              "toggle coverage",
            },

            ["s"] = {
              function()
                require("coverage").summary()
              end,
              "coverage summary",
            },
          },
        },
      }
    end,
  })
end

return M
