-- https://github.com/petertriho/nvim-scrollbar
local M = {}

M.name = "petertriho/nvim-scrollbar"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "petertriho/nvim-scrollbar",
        -- TODO: @cenk1cenk2 drop the branch once v2 lands on main on 2026-11-16, https://github.com/petertriho/nvim-scrollbar/issues/121
        branch = "refactor/v2",
        event = "BufReadPre",
      }
    end,
    setup = function()
      return {
        marks = {
          Search = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 0, highlight = { fg = nvim.ui.colors.magenta[900] } },
          Error = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 1, highlight = { fg = nvim.ui.colors.red[900] } },
          Warn = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 2, highlight = { fg = nvim.ui.colors.yellow[900] } },
          Info = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 3, highlight = { fg = nvim.ui.colors.blue[600] } },
          Hint = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 4, highlight = { fg = nvim.ui.colors.cyan[600] } },
          Misc = { text = { nvim.ui.icons.ui.SquareCentered }, priority = 5, highlight = { fg = nvim.ui.colors.purple[600] } },
        },
        exclude = {
          filetypes = nvim.disabled_filetypes,
        },
        providers = {
          diagnostic = true,
          search = true,
        },
        scrollbar = {
          show = true,
          thumb = {
            text = " ",
            highlight = { bg = nvim.ui.colors.bg[500] },
            hide_if_all_visible = true, -- Hides thumb if all lines are visible
          },
          events = {
            "BufWinEnter",
            "TabEnter",
            "TermEnter",
            "WinEnter",
            "CmdwinLeave",
            "TextChanged",
            "TextChangedI",
            "VimResized",
            "WinScrolled",
          },
        },
      }
    end,
    on_setup = function(c)
      require("scrollbar").setup(c)
    end,
  })
end

return M
