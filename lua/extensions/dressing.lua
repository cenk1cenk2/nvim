-- https://github.com/stevearc/dressing.nvim
local M = {}

local extension_name = "dressing"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
      }
    end,
    setup = function()
      return {
        input = {
          -- Default prompt string
          default_prompt = lvim.ui.icons.ui.ChevronRight .. " ",

          -- When true, <Esc> will close the modal
          insert_only = false,

          -- These are passed to nvim_open_win
          relative = "editor",
          border = lvim.ui.border,

          -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          prefer_width = 60,
          max_width = nil,
          min_width = 20,

          mappings = {
            n = {
              ["<Esc>"] = "Close",
              ["<CR>"] = "Confirm",
            },
            i = {
              ["<C-c>"] = "Close",
              ["<CR>"] = "Confirm",
              ["<Up>"] = "HistoryPrev",
              ["<Down>"] = "HistoryNext",
            },
          },

          -- see :help dressing-prompt
          prompt_buffer = false,

          -- see :help dressing_get_config
          get_config = nil,
        },
        select = {
          -- Priority list of preferred vim.select implementations
          backend = { "telescope", "fzf", "builtin", "nui" },

          -- Options for telescope selector
          telescope = require("telescope.themes").get_dropdown({}),

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
