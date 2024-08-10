-- https://github.com/lewis6991/gitsigns.nvim
local M = {}

M.name = "lewis6991/gitsigns.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
        cmd = { "Gitsigns" },
      }
    end,
    setup = function()
      return {
        signs = {
          add = {
            text = lvim.ui.icons.ui.BoldLineLeft,
          },
          change = {
            text = lvim.ui.icons.ui.BoldLineLeft,
          },
          delete = {
            -- text = lvim.ui.icons.ui.BoldLineLeft,
            text = lvim.ui.icons.ui.BoldDividerRight,
          },
          topdelete = {
            -- text = lvim.ui.icons.ui.BoldLineLeft,
            text = lvim.ui.icons.ui.BoldDividerRight,
          },
          changedelete = {
            text = lvim.ui.icons.ui.BoldLineLeft,
          },
        },
        numhl = false,
        linehl = false,
        signcolumn = true,
        word_diff = false,
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          relative_time = false,
        },
        max_file_length = 40000,
        preview_config = {
          -- Options passed to nvim_open_win
          border = lvim.ui.border,
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        sign_priority = 6,
        update_debounce = 200,
        status_formatter = nil, -- Use default
      }
    end,
    on_setup = function(config)
      require("gitsigns").setup(config.setup)
    end,
    keymaps = function()
      return {
        {
          "]h",
          ":Gitsigns next_hunk<CR>",
          desc = "next git hunk",
          mode = { "n" },
        },
        {
          "[h",
          ":Gitsigns prev_hunk<CR>",
          desc = "previous git hunk",
          mode = { "n" },
        },
      }
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.GIT, "D" }),
          function()
            vim.cmd([[Gitsigns diffthis]])
          end,
          desc = "diff current buffer with head",
        },
        {
          fn.wk_keystroke({ categories.GIT, "B" }),
          function()
            vim.cmd([[Gitsigns toggle_current_line_blame]])
          end,
          desc = "git blame",
        },
        {
          fn.wk_keystroke({ categories.GIT, "n" }),
          function()
            vim.cmd([[Gitsigns next_hunk]])
          end,
          desc = "next hunk",
        },
        {
          fn.wk_keystroke({ categories.GIT, "p" }),
          function()
            vim.cmd([[Gitsigns prev_hunk]])
          end,
          desc = "prev hunk",
        },
        {
          fn.wk_keystroke({ categories.GIT, "b" }),
          function()
            vim.cmd([[Gitsigns blame_line]])
          end,
          desc = "git hover blame",
        },
        {
          fn.wk_keystroke({ categories.GIT, "k" }),
          function()
            vim.cmd([[Gitsigns preview_hunk]])
          end,
          desc = "preview hunk",
        },
        {
          fn.wk_keystroke({ categories.GIT, "r" }),
          function()
            vim.cmd([[Gitsigns refresh]])
          end,
          desc = "refresh",
        },
        {
          fn.wk_keystroke({ categories.GIT, "R" }),
          group = "reset",
        },
        {
          fn.wk_keystroke({ categories.GIT, "R", "R" }),
          function()
            vim.cmd([[Gitsigns reset_buffer]])
          end,
          desc = "reset buffer",
        },
        {
          fn.wk_keystroke({ categories.GIT, "s" }),
          function()
            vim.cmd([[Gitsigns stage_hunk]])
          end,
          desc = "stage hunk",
        },
        {
          fn.wk_keystroke({ categories.GIT, "S" }),
          function()
            vim.cmd([[Gitsigns stage_buffer]])
          end,
          desc = "stage buffer",
        },
        {
          fn.wk_keystroke({ categories.GIT, "u" }),
          function()
            vim.cmd([[Gitsigns undo_stage_hunk]])
          end,
          desc = "undo stage hunk",
        },
        {
          fn.wk_keystroke({ categories.GIT, "U" }),
          function()
            vim.cmd([[Gitsigns reset_hunk]])
          end,
          desc = "reset hunk",
        },
        {
          fn.wk_keystroke({ categories.GIT, "q" }),
          function()
            vim.cmd([[Gitsigns setqflist]])
          end,
          desc = "set quickfix for current buffer changes",
        },
      }
    end,
  })
end

return M
