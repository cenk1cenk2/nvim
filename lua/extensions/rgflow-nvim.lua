-- https://github.com/mangelozzi/rgflow.nvim
local M = {}

local extension_name = "mangelozzi/rgflow.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "mangelozzi/rgflow.nvim",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "rgflow",
      })
    end,
    setup = function()
      return {
        -- Set the default rip grep flags and options for when running a search via
        -- RgFlow. Once changed via the UI, the previous search flags are used for
        -- each subsequent search (until Neovim restarts).
        cmd_flags = table.concat({
          "--glob=!.git/",
          "--smart-case",
          "--hidden",
          "--fixed-strings",
        }, " "),

        -- Mappings to trigger RgFlow functions
        default_trigger_mappings = false,
        -- These mappings are only active when the RgFlow UI (panel) is open
        default_ui_mappings = true,
        -- QuickFix window only mapping
        default_quickfix_mappings = true,
      }
    end,
    on_setup = function(config)
      require("rgflow").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        -- find and replace
        [categories.SEARCH] = {
          r = {
            function()
              require("rgflow").open_again()
            end,
            "[rgflow] open",
          },
          R = {
            function()
              require("rgflow").open_cword()
            end,
            "[rgflow] open cword",
          },
        },
      }
    end,
    autocmds = {
      require("modules.autocmds").q_close_autocmd({ "rgflow" }),
    },
  })
end

return M
