-- https://github.com/folke/noice.nvim
local M = {}

local extension_name = "noice_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "folke/noice.nvim",
        config = function()
          require("utils.setup").packer_config "noice_nvim"
        end,
        requires = {
          "MunifTanjim/nui.nvim",
        },
        disable = not config.active,
      }
    end,
    configure = function()
      table.insert(lvim.disabled_filetypes, "cmdline_popup")
      table.insert(lvim.disabled_filetypes, "noice")
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
      }
    end,
    setup = {
      cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        opts = { lang = "vim" }, -- enable syntax highlighting in the cmdline
        ---@type table<string, CmdlineFormat>
        format = {
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          cmdline = { pattern = "^:", icon = "" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          shell = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
          lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
          -- lua = false, -- to disable a format, set to `false`
        },
      },
      messages = {
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true, -- enables the Noice messages UI
        view = "notify", -- default view for messages
        view_error = "notify", -- view for errors
        view_warn = "notify", -- view for warnings
        view_history = "split", -- view for :messages
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
        enabled = true, -- enables the Noice popupmenu UI
        ---@type 'nui'|'cmp'
        backend = "cmp", -- backend to use to show regular cmdline completions
        ---@type NoicePopupmenuItemKind|false
        -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
        kind_icons = {}, -- set to `false` to disable icons
      },
      history = {
        -- options for the message history that you get with `:Noice`
        view = "split",
        opts = { enter = true, format = "details" },
        filter = { event = { "msg_show", "notify" }, ["not"] = { kind = { "search_count", "echo" } } },
      },
      views = {
        cmdline_popup = {
          border = {
            style = "single",
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
            -- col = 0,
          },
          size = "auto",
          border = {
            style = "single",
          },
          zindex = 60,
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
            row = "75%",
            col = "50%",
          },
          size = "auto",
          border = {
            style = "single",
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
      },
      lsp_progress = {
        enabled = true,
        -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
        -- See the section on formatting for more details on how to customize.
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30, -- frequency to update lsp progress message
        view = "mini",
      },

      throttle = 1000 / 30,
      routes = {
        {
          filter = { event = "msg_show", kind = { "search_count", "echo", "echomsg" } },
          opts = { skip = true },
        },
        {
          filter = { event = "split", kind = { "search_count" } },
          opts = { skip = true },
        },
        {
          view = "notify",
          filter = {
            event = "noice",
            kind = { "stats", "debug", "echo" },
          },
          opts = { replace = true },
        },
        {
          view = "mini",
          filter = { event = "msg_showmode" },
          opts = {
            timeout = 5000,
          },
        },
      },
    },
    on_setup = function(config)
      require("noice").setup(config.setup)
      vim.o.cmdheight = 0
    end,
    on_done = function(config)
      config.inject.telescope.load_extension "noice"
    end,
    wk = {
      ["N"] = { ":Noice<CR>", "messages" },
    },
  })
end

return M
