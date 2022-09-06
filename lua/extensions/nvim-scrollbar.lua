-- https://github.com/petertriho/nvim-scrollbar

local setup = require "utils.setup"

local M = {}

local extension_name = "nvim_scrollbar"
local colors = require "onedarker.colors"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "petertriho/nvim-scrollbar",
        config = function()
          require("utils.setup").packer_config "nvim_scrollbar"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      show = true,
      handle = {
        text = " ",
        color = colors.bg2,
        hide_if_all_visible = true, -- Hides handle if all lines are visible
      },
      marks = {
        Search = { text = { "█", "█" }, priority = 0, color = colors.bright_cyan },
        Error = { text = { "█", "█" }, priority = 1, color = colors.bright_red },
        Warn = { text = { "█", "█" }, priority = 2, color = colors.bright_yellow },
        Info = { text = { "█", "█" }, priority = 3, color = colors.dark_cyan },
        Hint = { text = { "█", "█" }, priority = 4, color = colors.dark_cyan },
        Misc = { text = { "█", "█" }, priority = 5, color = colors.purple },
      },
      excluded_filetypes = {
        "prompt",
        "TelescopePrompt",
        "notify",
        "spectre_panel",
        "Outline",
        "packer",
        "qf",
        "lsp_floating_window",
        "NvimTree",
        "neo-tree",
      },
      autocmd = {
        render = {
          "BufWinEnter",
          "TabEnter",
          "TermEnter",
          "WinEnter",
          "CmdwinLeave",
          "TextChanged",
          "VimResized",
          "WinScrolled",
        },
      },
      handlers = {
        diagnostic = true,
        search = true,
      },
    },
    on_setup = function(config)
      require("scrollbar").setup(config.setup)
    end,
  })
end

return M
