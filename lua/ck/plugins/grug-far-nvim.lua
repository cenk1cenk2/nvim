-- https://github.com/MagicDuck/grug-far.nvim
local M = {}

M.name = "MagicDuck/grug-far.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
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
      ---@type GrugFarOptionsOverride
      return {
        debounceMs = 500,
        minSearchChars = 2,
        maxWorkers = 10,
        startInInsertMode = false,
        windowCreationCommand = "vsplit",
        keymaps = {
          replace = { n = "<localleader>r" },
          qflist = { n = "Q" },
          syncLocations = { n = "<localleader>s" },
          syncLine = { n = "<localleader>l" },
          close = { n = "q" },
          historyOpen = { n = "<localleader>h" },
          historyAdd = { n = "<localleader>a" },
          refresh = { n = "R" },
          gotoLocation = { n = "<enter>" },
          pickHistoryEntry = { n = "<enter>" },
        },
        icons = {
          -- whether to show icons
          enabled = true,

          actionEntryBullet = ("%s "):format(nvim.ui.icons.ui.DoubleChevronRight),

          searchInput = ("%s "):format(nvim.ui.icons.ui.Search),
          replaceInput = ("%s "):format(nvim.ui.icons.ui.Files),
          filesFilterInput = ("%s "):format(nvim.ui.icons.ui.Filter),
          flagsInput = ("%s "):format("󰮚"),

          resultsStatusReady = ("%s "):format("󱩾"),
          resultsStatusError = ("%s "):format(nvim.ui.icons.diagnostics.Error),
          resultsStatusSuccess = ("%s "):format(nvim.ui.icons.diagnostics.Success),
          resultsActionMessage = ("%s "):format(nvim.ui.icons.diagnostics.Information),
          resultsChangeIndicator = ("%s "):format(nvim.ui.icons.ui.LineMiddle),

          historyTitle = ("%s "):format(nvim.ui.icons.ui.History),
        },
        history = {
          historyDir = join_paths(get_state_dir(), "grug-far"),
        },
      }
    end,
    on_setup = function(c)
      require("grug-far").setup(c)
    end,
    wk = function(_, categories, fn)
      local function generate_rg_flags(f)
        return table.concat(vim.list_extend(nvim.fn.get_telescope_args(true), f or {}), " ")
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
          fn.wk_keystroke({ categories.SEARCH, "w" }),
          function()
            local opts = {
              prefills = {
                search = "",
                replacement = "",
                filesFilter = string.format("%s/**", require("ck.utils.fs").get_project_buffer_dirpath()),
                flags = generate_rg_flags({ "--no-ignore-dot" }),
              },
            }

            require("grug-far").grug_far(opts)
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
                filesFilter = require("ck.utils.fs").get_project_buffer_filepath(),
                flags = generate_rg_flags({ "--no-ignore-dot" }),
              },
            }

            require("grug-far").grug_far(opts)
          end,
          desc = "[grug-far] find and replace in current buffer",
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
                  filesFilter = string.format("%s/**", require("ck.utils.fs").get_project_buffer_dirpath()),
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
                  filesFilter = require("ck.utils.fs").get_project_buffer_filepath(),
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
    autocmds = function()
      local function grug_far_toggle_flags(flags)
        local status = require("grug-far").toggle_flags(flags)
        local state = unpack(status) and "ON" or "OFF"
        vim.notify(("Grug Far: toggled %s: %s"):format(table.concat(flags, " "), state))
      end

      return {
        require("ck.modules.autocmds").q_close_autocmd({ "grug-far-history" }),
        require("ck.modules.autocmds").setup_init_for_filetype({ "grug-far" }, function(event)
          return {
            keymaps = {

              {
                "<localleader>w",
                function()
                  return grug_far_toggle_flags({ "--fixed-strings" })
                end,
                desc = "Grug Far: toggle --fixed-strings",
                mode = { "n" },
                buffer = event.buf,
              },
              {
                "<localleader>i",
                function()
                  return grug_far_toggle_flags({ "--no-ignore-dot" })
                end,
                mode = { "n" },
                desc = "Grug Far: toggle --no-ignore-dot",
                buffer = event.buf,
              },
              {
                "<localleader>x",
                function()
                  return grug_far_toggle_flags({ "--replace=" })
                end,
                mode = { "n" },
                desc = "Grug Far: toggle replace empty",
                buffer = event.buf,
              },
            },
          }
        end),
      }
    end,
  })
end

return M
