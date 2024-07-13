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
    wk = function(_, categories, fn)
      local function generate_rg_flags(f)
        return table.concat(vim.list_extend(lvim.fn.get_telescope_rg_arguments(true), f or {}), " ")
      end

      return {
        {
          fn.wk_keystroke({ categories.SEARCH, "s" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = "",
                flags = generate_rg_flags({}),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace",
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "S" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = "",
                flags = generate_rg_flags({ "--fixed-strings" }),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace (fixed strings)",
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "w" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = string.format("%s**", require("utils").get_project_buffer_dirpath()),
                flags = generate_rg_flags({ "--no-ignore-dot" }),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace in current folder",
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "W" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = string.format("%s**", require("utils").get_project_buffer_dirpath()),
                flags = generate_rg_flags({ "--no-ignore-dot", "--fixed-strings" }),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace in current folder (fixed strings)",
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "b" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = require("utils").get_project_buffer_filepath(),
                flags = generate_rg_flags({ "--no-ignore-dot" }),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace in current buffer",
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "B" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = require("utils").get_project_buffer_filepath(),
                flags = generate_rg_flags({ "--no-ignore-dot", "--fixed-strings" }),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace in current buffer (fixed strings)",
        },
        {
          mode = { "v" },
          {
            fn.wk_keystroke({ categories.SEARCH, "s" }),
            function()
              local opts = {
                prefills = {
                  search = "",
                  replacement = "",
                  filesFilter = "",
                  flags = generate_rg_flags({}),
                },
              }

              require("grug-far").with_visual_selection(opts)
            end,
            desc = "[grug-far] find and replace",
          },
          {
            fn.wk_keystroke({ categories.SEARCH, "w" }),
            function()
              local opts = {
                prefills = {
                  search = "",
                  replacement = "",
                  filesFilter = string.format("%s**", require("utils").get_project_buffer_dirpath()),
                  flags = generate_rg_flags({ "--no-ignore-dot" }),
                },
              }

              require("grug-far").with_visual_selection(opts)
            end,
            desc = "[grug-far] find and replace in current folder",
          },
          {
            fn.wk_keystroke({ categories.SEARCH, "b" }),
            function()
              local opts = {
                prefills = {
                  search = "",
                  replacement = "",
                  filesFilter = require("utils").get_project_buffer_filepath(),
                  flags = generate_rg_flags({ "--no-ignore-dot" }),
                },
              }

              require("grug-far").with_visual_selection(opts)
            end,
            desc = "[grug-far] find and replace in current buffer",
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
