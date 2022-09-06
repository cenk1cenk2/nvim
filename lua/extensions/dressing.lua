-- https://github.com/stevearc/dressing.nvim

local setup = require "utils.setup"

local M = {}

local extension_name = "dressing"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "stevearc/dressing.nvim",
        config = function()
          require("utils.setup").packer_config "dressing"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        telescope_themes = require "telescope.themes",
      }
    end,
    setup = function(config)
      return {
        input = {
          -- Default prompt string
          default_prompt = "➤ ",

          -- When true, <Esc> will close the modal
          insert_only = true,

          -- These are passed to nvim_open_win
          anchor = "SW",
          relative = "cursor",
          border = "single",

          -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          prefer_width = 40,
          max_width = nil,
          min_width = 20,

          -- Window transparency (0-100)
          winblend = 0,

          -- see :help dressing-prompt
          prompt_buffer = false,

          -- see :help dressing_get_config
          get_config = nil,
        },
        select = {
          -- Priority list of preferred vim.select implementations
          backend = { "telescope", "fzf", "builtin", "nui" },

          -- Options for telescope selector
          telescope = config.inject.telescope_themes.get_dropdown {},

          -- see :help dressing_get_config
          get_config = nil,
        },
      }
    end,
    on_setup = function(config)
      require("dressing").setup(config.setup)
    end,
  })
end

return M
