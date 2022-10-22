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
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
      }
    end,
    setup = {
      -- popupmenu = {
      --   enabled = true, -- disable if you use something like cmp-cmdline
      --   ---@type 'nui'|'cmp'
      --   backend = "nui", -- backend to use to show regular cmdline completions
      --   -- You can specify options for nui under `config.views.popupmenu`
      -- },
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
          filter = { event = "msg_show", kind = { "search_count", "echo" } },
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
          opts = { buf_options = { filetype = "lua" }, replace = true },
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
