-- https://github.com/petertriho/nvim-scrollbar
local M = {}

local extension_name = "nvim_scrollbar"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "petertriho/nvim-scrollbar",
        event = "BufReadPre",
      }
    end,
    setup = function()
      return {
        show = true,
        handle = {
          text = " ",
          color = lvim.ui.colors.bg[400],
          hide_if_all_visible = true, -- Hides handle if all lines are visible
        },
        marks = {
          Search = { text = { lvim.ui.icons.ui.SquareCentered }, priority = 0, color = lvim.ui.colors.magenta[900] },
          Error = { text = { lvim.ui.icons.ui.SquareCentered }, priority = 1, color = lvim.ui.colors.red[900] },
          Warn = { text = { lvim.ui.icons.ui.SquareCentered }, priority = 2, color = lvim.ui.colors.yellow[900] },
          Info = { text = { lvim.ui.icons.ui.SquareCentered }, priority = 3, color = lvim.ui.colors.blue[600] },
          Hint = { text = { lvim.ui.icons.ui.SquareCentered }, priority = 4, color = lvim.ui.colors.cyan[600] },
          Misc = { text = { lvim.ui.icons.ui.SquareCentered }, priority = 5, color = lvim.ui.colors.purple[600] },
        },
        excluded_filetypes = lvim.disabled_filetypes,
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
      }
    end,
    on_setup = function(config)
      require("scrollbar").setup(config.setup)
    end,
  })
end

return M
