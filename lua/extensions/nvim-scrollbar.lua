-- https://github.com/petertriho/nvim-scrollbar
local M = {}

local extension_name = "nvim_scrollbar"
local c = require "onedarker.colors"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
        color = c.bg[400],
        hide_if_all_visible = true, -- Hides handle if all lines are visible
      },
      marks = {
        Search = { text = { "⯀" }, priority = 0, color = c.magenta[900] },
        Error = { text = { "⯀" }, priority = 1, color = c.red[900] },
        Warn = { text = { "⯀" }, priority = 2, color = c.yellow[900] },
        Info = { text = { "⯀" }, priority = 3, color = c.blue[600] },
        Hint = { text = { "⯀" }, priority = 4, color = c.cyan[600] },
        Misc = { text = { "⯀" }, priority = 5, color = c.purple[600] },
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
