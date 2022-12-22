-- https://github.com/lewis6991/gitsigns.nvim
local M = {}

local extension_name = "gitsigns_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
      }
    end,
    setup = {
      signs = {
        add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        change = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        delete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
        topdelete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
        changedelete = {
          hl = "GitSignsChange",
          text = "▎",
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
      },
      numhl = false,
      linehl = false,
      keymaps = {
        -- Default keymap options
        noremap = true,
        buffer = true,
      },
      signcolumn = true,
      word_diff = false,
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter_opts = {
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
      yadm = { enable = false },
    },
    on_setup = function(config)
      require("gitsigns").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.GIT] = {
          B = { ":Gitsigns toggle_current_line_blame<CR>", "git blame" },
          n = { ":Gitsigns next_hunk<CR>", "next hunk" },
          p = { ":Gitsigns prev_hunk<CR>", "prev hunk" },
          b = { ":Gitsigns blame_line<CR>", "git hover blame" },
          k = { ":Gitsigns preview_hunk<CR>", "preview hunk" },
          U = { ":Gitsigns reset_hunk<CR>", "reset hunk" },
          R = {
            R = { ":Gitsigns reset_buffer<CR>", "reset buffer" },
          },
          s = { ":Gitsigns stage_hunk<CR>", "stage hunk" },
          S = { ":Gitsigns undo_stage_hunk<CR>", "undo stage hunk" },
        },
      }
    end,
  })
end

return M
