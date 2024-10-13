-- https://github.com/folke/noice.nvim
local M = {}

M.name = "folke/noice.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/noice.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim",
          "rcarriga/nvim-notify",
        },
        event = "UIEnter",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "cmdline_popup",
        "noice",
      })

      -- fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
      --   vim.list_extend(c.bottom, {
      --     {
      --       ft = "noice",
      --       title = "Noice",
      --       size = { height = 35 },
      --     },
      --   })
      --
      --   return c
      -- end)
    end,
    setup = function()
      ---@type NoiceConfig
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
            cmdline = { pattern = "^:", icon = nvim.ui.icons.ui.Command },
            search_down = { kind = "search", pattern = "^/", icon = ("%s %s"):format(nvim.ui.icons.ui.Search, nvim.ui.icons.ui.DoubleChevronDown), lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = ("%s %s"):format(nvim.ui.icons.ui.Search, nvim.ui.icons.ui.DoubleChevronUp), lang = "regex" },
            shell = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
            -- lua = false, -- to disable a format, set to `false`
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = nvim.ui.icons.ui.CircleQuestion },
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
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = { "search_count" },
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = "msg_show",
              kind = "",
              -- find = "written",
            },
            opts = { skip = true },
          },
          {
            view = "notify",
            filter = {
              event = "msg_show",
              kind = { "echomsg" },
            },
            opts = { skip = true },
          },
          {
            view = "notify",
            filter = {
              event = "noice",
              kind = { "stats", "debug" },
            },
            opts = { replace = true },
          },
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
          cmdline_popup = {
            border = {
              style = nvim.ui.border,
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
            -- reverse = true,
            -- position = {
            --   col = "50%",
            --   row = "97%",
            -- },
            reverse = false,
            position = {
              row = 2,
              col = -2,
            },
            border = {
              style = nvim.ui.border,
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
            align = "center",
            position = {
              col = "50%",
              row = "75%",
            },
            border = {
              style = nvim.ui.border,
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
            border = {
              style = nvim.ui.border,
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
            border = {
              style = nvim.ui.border,
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
                style = nvim.ui.border,
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
      }
    end,
    on_setup = function(c)
      require("noice").setup(c)
      vim.o.cmdheight = 0
    end,
    on_done = function(config)
      -- require("telescope").load_extension("noice")
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ "M" }),
          function()
            vim.cmd([[Noice]])
          end,
          desc = "messages [noice]",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "n" }),
          function()
            vim.cmd([[Noice enable]])
          end,
          desc = "enable noice",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "N" }),
          function()
            vim.cmd([[Noice disable]])
          end,
          desc = "disable noice",
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").set_view_buffer({ "noice" }),
      }
    end,
  })
end

return M
