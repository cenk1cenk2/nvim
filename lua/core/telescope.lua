local M = {}

local utils = require 'utils'

function M.config()
  -- Define this minimal config so that it's available if telescope is not yet available.
  lvim.builtin.telescope = {
    ---@usage disable telescope completely [not recommeded]
    active = true,
    on_config_done = nil
  }

  local status_ok, actions = pcall(require, 'telescope.actions')
  if not status_ok then return end

  M.rg_arguments = {'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden', '--ignore'}

  lvim.builtin.telescope = vim.tbl_extend('force', lvim.builtin.telescope, {
    defaults = {
      find_command = M.rg_arguments,
      vimgrep_arguments = M.rg_arguments,
      prompt_prefix = '🔍 ',
      selection_caret = ' ',
      entry_prefix = '  ',
      layout_config = {prompt_position = 'bottom', horizontal = {mirror = false, width = 0.9}, vertical = {mirror = false, width = 0.8}},
      file_ignore_patterns = {'**/yarn.lock', '**/node_modules/**', '**/package-lock.json', '**/.git'},
      mappings = {i = {['<C-e>'] = actions.cycle_previewers_next, ['<C-r>'] = actions.cycle_previewers_prev}},
      initial_mode = 'insert',
      selection_strategy = 'reset',
      sorting_strategy = 'descending',
      layout_strategy = 'horizontal',
      file_sorter = require('telescope.sorters').get_fzy_sorter,
      generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
      path_display = {shorten = 5},
      winblend = 0,
      border = {},
      borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
      color_devicons = true,
      use_less = true,
      set_env = {['COLORTERM'] = 'truecolor'}, -- default = nil,
      file_previewer = require('telescope.previewers').vim_buffer_cat.new,
      grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
      qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new

      -- Developer configurations: Not meant for general override
      -- buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    },
    pickers = {
      -- Your special builtin config goes in here
      buffers = {
        sort_lastused = true,
        theme = 'dropdown',
        previewer = false,
        mappings = {i = {['<c-d>'] = 'delete_buffer'}, n = {['<c-d>'] = require('telescope.actions').delete_buffer}}
      },
      find_files = {theme = 'dropdown'}
    },
    extensions = {fzy_native = {override_generic_sorter = false, override_file_sorter = true}}
  })
end

function M.find_lunarvim_files(opts)
  opts = opts or {}
  local themes = require 'telescope.themes'
  local theme_opts = themes.get_ivy {
    sorting_strategy = 'ascending',
    layout_strategy = 'bottom_pane',
    prompt_prefix = '>> ',
    prompt_title = '~ LunarVim files ~',
    cwd = utils.join_paths(get_runtime_dir(), 'lvim'),
    find_command = {'git', 'ls-files'}
  }
  opts = vim.tbl_deep_extend('force', theme_opts, opts)
  require('telescope.builtin').find_files(opts)
end

function M.grep_lunarvim_files(opts)
  opts = opts or {}
  local themes = require 'telescope.themes'
  local theme_opts = themes.get_ivy {
    sorting_strategy = 'ascending',
    layout_strategy = 'bottom_pane',
    prompt_prefix = '>> ',
    prompt_title = '~ search LunarVim ~',
    cwd = utils.join_paths(get_runtime_dir(), 'lvim')
  }
  opts = vim.tbl_deep_extend('force', theme_opts, opts)
  require('telescope.builtin').live_grep(opts)
end

function M.view_lunarvim_changelog()
  local finders = require 'telescope.finders'
  local make_entry = require 'telescope.make_entry'
  local pickers = require 'telescope.pickers'
  local previewers = require 'telescope.previewers'
  local actions = require 'telescope.actions'
  local opts = {}

  local conf = require('telescope.config').values
  opts.entry_maker = make_entry.gen_from_git_commits(opts)

  pickers.new(opts, {
    prompt_title = 'LunarVim changelog',

    finder = finders.new_oneshot_job(vim.tbl_flatten {'git', 'log', '--pretty=oneline', '--abbrev-commit', '--', '.'}, opts),
    previewer = {
      previewers.git_commit_diff_to_parent.new(opts),
      previewers.git_commit_diff_to_head.new(opts),
      previewers.git_commit_diff_as_was.new(opts),
      previewers.git_commit_message.new(opts)
    },

    -- TODO: consider opening a diff view when pressing enter
    attach_mappings = function(_, map)
      map('i', '<enter>', actions._close)
      map('n', '<enter>', actions._close)
      map('i', '<esc>', actions._close)
      map('n', '<esc>', actions._close)
      map('n', 'q', actions._close)
      return true
    end,
    sorter = conf.file_sorter(opts)
  }):find()
end

function M.code_actions()
  local opts = {
    winblend = 15,
    layout_config = {prompt_position = 'top', width = 80, height = 12},
    borderchars = {
      prompt = {'─', '│', ' ', '│', '╭', '╮', '│', '│'},
      results = {'─', '│', '─', '│', '├', '┤', '╯', '╰'},
      preview = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'}
    },
    border = {},
    previewer = false,
    shorten_path = false
  }
  require('telescope.builtin').lsp_code_actions(require('telescope.themes').get_dropdown(opts))
end

function M.setup()
  local telescope = require 'telescope'

  telescope.setup(lvim.builtin.telescope)
  if lvim.builtin.project.active then telescope.load_extension 'projects' end

  if lvim.builtin.telescope.on_config_done then lvim.builtin.telescope.on_config_done(telescope) end
end

return M
