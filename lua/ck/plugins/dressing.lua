-- https://github.com/stevearc/dressing.nvim
local M = {}

M.name = "stevearc/dressing.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
      }
    end,
    configure = function()
      require("ck.setup").setup_callback(M.name, function(c)
        c.select.telescope.layout_config = require("telescope.themes").get_dropdown({
          layout_config = {
            preview_cutoff = 1,

            width = function(_, max_columns, _)
              return math.min(max_columns, 120)
            end,

            height = function(_, _, max_lines)
              return math.min(max_lines, 24)
            end,
          },
        })
      end)
    end,
    setup = function()
      return {
        input = {
          -- Default prompt string
          default_prompt = nvim.ui.icons.ui.ChevronRight .. " ",

          -- When true, <Esc> will close the modal
          insert_only = false,

          -- These are passed to nvim_open_win
          relative = "editor",
          border = nvim.ui.border,

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
          builtin = {
            border = nvim.ui.border,
          },

          nui = {
            border = nvim.ui.border,
          },

          -- Priority list of preferred vim.select implementations
          backend = { "telescope", "fzf", "builtin", "nui" },

          -- Options for telescope selector
          telescope = {
            theme = "dropdown",
            preview = true,
            results_title = false,

            sorting_strategy = "ascending",
            layout_strategy = "center",
            layout_config = {
              preview_cutoff = 1, -- Preview should always show (unless previewer = false)

              width = function(_, max_columns, _)
                return math.min(max_columns, 120)
              end,

              height = function(_, _, max_lines)
                return math.min(max_lines, 24)
              end,
            },
          },

          -- see :help dressing_get_config
          get_config = nil,
        },
      }
    end,
    on_setup = function(c)
      require("dressing").setup(c)
    end,
  })
end

return M
