-- https://github.com/petertriho/nvim-scrollbar
local M = {}

M.name = "petertriho/nvim-scrollbar"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
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
          color = nvim.ui.colors.bg[500],
          hide_if_all_visible = true, -- Hides handle if all lines are visible
        },
        marks = {
          Search = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 0, color = nvim.ui.colors.magenta[900] },
          Error = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 1, color = nvim.ui.colors.red[900] },
          Warn = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 2, color = nvim.ui.colors.yellow[900] },
          Info = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 3, color = nvim.ui.colors.blue[600] },
          Hint = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 4, color = nvim.ui.colors.cyan[600] },
          Misc = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 5, color = nvim.ui.colors.purple[600] },
        },
        excluded_filetypes = nvim.disabled_filetypes,
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
    on_setup = function(c)
      require("scrollbar").setup(c)
    end,
  })
end

return M
