-- https://github.com/folke/noice.nvim
local M = {}

local extension_name = "noice_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "folke/noice.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim",
          "rcarriga/nvim-notify",
        },
        event = "VeryLazy",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "cmdline_popup",
        "noice",
      })
    end,
    inject_to_configure = function()
      return {
        telescope = require("telescope"),
        noice_util = require("noice.util"),
      }
    end,
    setup = function(config)
      local noice_util = config.inject.noice_util

      return {
        presets = {
          bottom_search = false, -- use a classic bottom cmdline for search
          command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        cmdline = {
          ---@type table<string, CmdlineFormat>
          format = {
            -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
            -- view: (default is cmdline view)
            -- opts: any options passed to the view
            -- icon_hl_group: optional hl_group for the icon
            cmdline = { pattern = "^:", icon = lvim.icons.ui.Command },
            search_down = { kind = "search", pattern = "^/", icon = ("%s %s"):format(lvim.icons.ui.Search, lvim.icons.ui.DoubleChevronDown), lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = ("%s %s"):format(lvim.icons.ui.Search, lvim.icons.ui.DoubleChevronUp), lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            shell = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
            -- lua = false, -- to disable a format, set to `false`
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = lvim.icons.ui.CircleQuestion },
            input = {}, -- Used by input()
          },
        },
        messages = {
          view_search = false, -- view for search count messages. Set to `false` to disable
        },
        notify = {
          -- Noice can be used as `vim.notify` so you can route any notification like other messages
          -- Notification messages have their level and other properties set.
          -- event is always "notify" and kind can be any log level as a string
          -- The default routes will forward notifications to nvim-notify
          -- Benefit of using Noice for this is the routing and consistent history view
          enabled = true,
          view = "notify",
        },
        popupmenu = {
          backend = "cmp", -- backend to use to show regular cmdline completions
        },
        views = {
          split = {
            backend = "split",
            enter = true,
            relative = "editor",
            position = "bottom",
            size = "40%",
            close = {
              keys = { "q", "<esc>" },
            },
            win_options = {
              winhighlight = { Normal = "NoiceSplit", FloatBorder = "NoiceSplitBorder" },
              wrap = true,
            },
          },
          vsplit = {
            view = "split",
            position = "right",
          },
          cmdline_popup = {
            border = {
              style = lvim.ui.border,
              padding = { 0, 1 },
            },
            filter_options = {},
            win_options = {
              winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
            },
          },
          mini = {
            backend = "mini",
            relative = "editor",
            align = "message-left",
            timeout = 1500,
            reverse = true,
            position = {
              col = "50%",
              row = "97%",
            },
            border = {
              style = lvim.ui.border,
            },
            win_options = {
              winblend = 30,
              winhighlight = {
                Normal = "NoiceMini",
                IncSearch = "",
                Search = "",
              },
            },
          },
          confirm = {
            backend = "popup",
            relative = "editor",
            focusable = false,
            align = "center",
            enter = false,
            zindex = 60,
            format = { "{confirm}" },
            position = {
              col = "50%",
              row = "75%",
            },
            border = {
              style = lvim.ui.border,
              padding = { 0, 1 },
              text = {
                top = " Confirm ",
              },
            },
            win_options = {
              winhighlight = {
                Normal = "NoiceConfirm",
                FloatBorder = "NoiceConfirmBorder",
              },
            },
          },
          popup = {
            backend = "popup",
            close = {
              events = { "BufLeave" },
              keys = { "q" },
            },
            enter = true,
            border = {
              style = lvim.ui.border,
            },
            position = {
              row = "75%",
              col = "50%",
            },
            size = {
              width = "80%",
              height = "60%",
            },
            win_options = {
              winhighlight = { Normal = "NoicePopup", FloatBorder = "NoicePopupBorder" },
            },
          },
          virtualtext = {
            backend = "virtualtext",
            format = { "{message}" },
            hl_group = "NoiceVirtualText",
          },
          hover = {
            view = "popup",
            relative = "cursor",
            enter = false,
            anchor = "auto",
            size = {
              width = "auto",
              height = "auto",
              max_height = 20,
              max_width = 120,
            },
            border = {
              style = lvim.ui.border,
              padding = { 0, 0 },
            },
            position = { row = 2, col = 0 },
            win_options = {
              wrap = true,
              linebreak = true,
            },
          },
        },
        lsp = {
          progress = {
            enabled = true,
          },
          override = {
            -- override the default lsp markdown formatter with Noice
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = true,
            -- override cmp documentation with Noice (needs the other options to work)
            ["cmp.entry.get_documentation"] = false,
          },
          hover = {
            enabled = true,
          },
          signature = {
            enabled = true,
            auto_open = {
              enabled = true,
              throttle = 100, -- Debounce lsp signature help request by 50ms
            },
          },
          -- defaults for hover and signature help
          documentation = {
            opts = {
              border = {
                style = lvim.ui.border,
                padding = { 0, 0 },
              },
            },
          },
        },
        smart_move = {
          -- noice tries to move out of the way of existing floating windows.
          enabled = true, -- you can disable this behaviour here
          -- add any filetypes here, that shouldn't trigger smart move.
          excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = { "search_count" },
            },
            opts = { replace = false, skip = true, stop = true },
          },
          {
            view = "split",
            filter = {
              event = "msg_show",
              kind = { "echo", "echomsg" },
              min_height = 5,
            },
            opts = { replace = false, skip = true, stop = true },
          },
          {
            view = "notify",
            filter = {
              event = "msg_show",
              kind = { "echo", "echomsg" },
            },
            opts = { replace = false, skip = true, stop = false },
          },
          {
            view = "notify",
            filter = {
              event = "noice",
              kind = { "stats", "debug" },
            },
            opts = { replace = true },
          },
          {
            view = "notify",
            filter = {
              event = "msg_showmode",
            },
            opts = { timeout = 10000 },
          },
        },
      }
    end,
    on_setup = function(config)
      require("noice").setup(config.setup)
      vim.o.cmdheight = 0
    end,
    on_done = function(config)
      config.inject.telescope.load_extension("noice")
    end,
    wk = {
      ["M"] = { ":Noice<CR>", "messages" },
    },
    autocmds = {
      {
        "FileType",
        {
          group = "__noice",
          pattern = "noice",
          command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell nolist nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs=",
        },
      },

      {
        "FileType",
        {
          group = "_buffer_mappings",
          pattern = {
            "noice",
          },
          callback = function(event)
            vim.keymap.set("n", "q", ":close<CR>", { silent = true, buffer = event.buf })
          end,
        },
      },
    },
  })
end

return M
