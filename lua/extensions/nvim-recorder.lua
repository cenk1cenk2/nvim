-- https://github.com/chrisgrieser/nvim-recorder
local M = {}

local extension_name = "nvim_recorder"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "chrisgrieser/nvim-recorder",
        keys = { "q", "Q", "@", "cq", "yq", "dq", "cq" },
      }
    end,
    setup = function()
      return {
        -- Named registers where macros are saved. The first register is the default
        -- register/macro-slot used after startup.
        slots = { "n", "m", "y", "u" },

        -- default keymaps, see README for description what the commands do
        mapping = {
          startStopRecording = "q",
          playMacro = "Q",
          switchSlot = "@",
          editMacro = "cq",
          deleteAllMacros = "dq",
          yankMacro = "yq",
          -- ⚠️ this should be a string you don't use in insert mode during a macro
          addBreakPoint = "##",
        },

        -- clears all macros-slots on startup
        clear = false,

        -- log level used for any notification, mostly relevant for nvim-notify
        -- (note that by default, nvim-notify does not show the levels trace and debug.)
        logLevel = vim.log.levels.WARN,

        -- experimental, see README
        dapSharedKeymaps = true,
      }
    end,
    on_setup = function(config)
      require("recorder").setup(config.setup)
    end,
    keymaps = {
      {
        { "n" },

        ["q"] = "<Nop>",
      },
    },
  })
end

return M
