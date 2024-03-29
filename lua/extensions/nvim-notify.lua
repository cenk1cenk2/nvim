-- https://github.com/rcarriga/nvim-notify
local M = {}

local extension_name = "nvim_notify"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
      return {
        ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
        stages = "slide",

        ---@usage Function called when a new window is opened, use for changing win settings/config
        on_open = function(win)
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { border = lvim.ui.border })
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
          ERROR = lvim.ui.icons.diagnostics.Error .. " ",
          WARN = lvim.ui.icons.diagnostics.Warning .. " ",
          INFO = lvim.ui.icons.diagnostics.Information .. " ",
          DEBUG = lvim.ui.icons.diagnostics.Debug .. " ",
          TRACE = lvim.ui.icons.diagnostics.Trace .. " ",
        },
      }
    end,
    on_setup = function(config)
      local notify = require("notify")
      notify.setup(config.setup)
      -- vim.notify = notify
    end,
    on_done = function()
      -- require("telescope").load_extension("notify")
    end,
  })
end

return M
