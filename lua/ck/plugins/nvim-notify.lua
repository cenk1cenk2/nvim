-- https://github.com/rcarriga/nvim-notify
local M = {}

M.name = "rcarriga/nvim-notify"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        cond = function()
          if is_headless() then
            -- no need to configure notifications in headless
            return false
          end

          return true
        end,
      }
    end,
    setup = function()
      ---@type notify.Config
      return {
        ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
        stages = "slide",

        ---@usage Function called when a new window is opened, use for changing win settings/config
        on_open = function(win)
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { border = nvim.ui.border })
          end
        end,

        ---@usage Function called when a window is closed
        on_close = nil,

        ---@usage timeout for notifications in ms, default 5000
        timeout = 3000,

        -- Render function for notifications. See notify-render()
        render = "minimal",

        ---@usage highlight behind the window for stages that change opacity
        background_colour = "NormalFloat",

        ---@usage minimum width for notification windows
        minimum_width = 50,

        fps = 60,

        top_down = false,

        ---@usage Icons for the different levels
        icons = {
          ERROR = nvim.ui.icons.diagnostics.Error .. " ",
          WARN = nvim.ui.icons.diagnostics.Warning .. " ",
          INFO = nvim.ui.icons.diagnostics.Information .. " ",
          DEBUG = nvim.ui.icons.diagnostics.Debug .. " ",
          TRACE = nvim.ui.icons.diagnostics.Trace .. " ",
        },
      }
    end,
    on_setup = function(c)
      local notify = require("notify")
      notify.setup(c)
      -- vim.notify = notify
    end,
    on_done = function()
      -- require("telescope").load_extension("notify")
    end,
  })
end

return M
