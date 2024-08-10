-- https://github.com/MagicDuck/grug-far.nvim
local M = {}

M.name = "MagicDuck/grug-far.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
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
    autocmds = function()
      local function grug_far_toggle_flags(flags)
        local status = require("grug-far").toggle_flags(flags)
        local state = unpack(status) and "ON" or "OFF"
        vim.notify(("Grug Far: toggled %s: %s"):format(table.concat(flags, " "), state))
      end
      return {
        require("modules.autocmds").q_close_autocmd({ "grug-far-history" }),
        {
          event = "FileType",
          group = "__grug_far",
          pattern = { "grug-far" },
          callback = function(event)
            require("utils.setup").load_mappings({
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
            })
          end,
        },
      }
    end,
  })
end

return M
