-- https://github.com/MagicDuck/grug-far.nvim
local M = {}

local extension_name = "MagicDuck/grug-far.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "MagicDuck/grug-far.nvim",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "grug-far",
        "grug-far-history",
      })
    end,
    setup = function()
      return {
        debounceMs = 500,
        minSearchChars = 2,
        maxWorkers = 10,
        startInInsertMode = false,
        windowCreationCommand = "vsplit",
        keymaps = {
          replace = { n = "tr" },
          qflist = { n = "Q" },
          syncLocations = { n = "ts" },
          syncLine = { n = "tl" },
          close = { n = "q" },
          historyOpen = { n = "th" },
          historyAdd = { n = "ta" },
          refresh = { n = "R" },
          gotoLocation = { n = "<enter>" },
          pickHistoryEntry = { n = "<enter>" },
        },
        icons = {
          -- whether to show icons
          enabled = true,

          actionEntryBullet = ("%s "):format(lvim.ui.icons.ui.DoubleChevronRight),

          searchInput = ("%s "):format(lvim.ui.icons.ui.Search),
          replaceInput = ("%s "):format(lvim.ui.icons.ui.Files),
          filesFilterInput = ("%s "):format(lvim.ui.icons.ui.Filter),
          flagsInput = ("%s "):format("󰮚"),

          resultsStatusReady = ("%s "):format("󱩾"),
          resultsStatusError = ("%s "):format(lvim.ui.icons.diagnostics.Error),
          resultsStatusSuccess = ("%s "):format(lvim.ui.icons.diagnostics.Success),
          resultsActionMessage = ("%s "):format(lvim.ui.icons.diagnostics.Information),
          resultsChangeIndicator = ("%s "):format(lvim.ui.icons.ui.LineMiddle),

          historyTitle = ("%s "):format(lvim.ui.icons.ui.History),
        },
        history = {
          historyDir = join_paths(get_state_dir(), "grug-far"),
        },
      }
    end,
    on_setup = function(config)
      require("grug-far").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        {
          { "n" },

          -- find and replace
          [categories.SEARCH] = {
            s = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = "",
                    flags = "",
                  },
                }

                require("grug-far").grug_far(opts)
              end,
              "[grug-far] find and replace",
            },
            S = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = "",
                    flags = "--fixed-strings",
                  },
                }

                require("grug-far").grug_far(opts)
              end,
              "[grug-far] find and replace (fixed strings)",
            },
            w = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = string.format("%s**", require("utils").get_project_buffer_dirpath()),
                    flags = "--no-ignore-dot",
                  },
                }

                require("grug-far").grug_far(opts)
              end,
              "[grug-far] find and replace in current folder",
            },
            W = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = string.format("%s**", require("utils").get_project_buffer_dirpath()),
                    flags = "--no-ignore-dot --fixed-strings",
                  },
                }

                require("grug-far").grug_far(opts)
              end,
              "[grug-far] find and replace in current folder (fixed strings)",
            },
            b = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = require("utils").get_project_buffer_filepath(),
                    flags = "--no-ignore-dot",
                  },
                }

                require("grug-far").grug_far(opts)
              end,
              "[grug-far] find and replace in current buffer",
            },
            B = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = require("utils").get_project_buffer_filepath(),
                    flags = "--no-ignore-dot --fixed-strings",
                  },
                }

                require("grug-far").grug_far(opts)
              end,
              "[grug-far] find and replace in current buffer (fixed strings)",
            },
          },
        },
        {
          { "v" },
          -- find and replace
          [categories.SEARCH] = {
            s = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = "",
                    flags = "",
                  },
                }

                require("grug-far").with_visual_selection(opts)
              end,
              "[grug-far] find and replace",
            },
            w = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = string.format("%s**", require("utils").get_project_buffer_dirpath()),
                    flags = "--no-ignore-dot",
                  },
                }

                require("grug-far").with_visual_selection(opts)
              end,
              "[grug-far] find and replace in current folder",
            },
            b = {
              function()
                local opts = {
                  prefills = {
                    search = "",
                    replacement = "",
                    filesFilter = require("utils").get_project_buffer_filepath(),
                    flags = "--no-ignore-dot",
                  },
                }

                require("grug-far").with_visual_selection(opts)
              end,
              "[grug-far] find and replace in current buffer",
            },
          },
        },
      }
    end,
    autocmds = {
      require("modules.autocmds").q_close_autocmd({ "grug-far-history" }),
    },
  })
end

return M
