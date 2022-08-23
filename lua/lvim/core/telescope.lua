local M = {}
M.rg_arguments = {
  "rg",
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--smart-case",
  "--hidden",
  "--glob=!.git/",
}

function M.config()
  -- Define this minimal config so that it's available if telescope is not yet available.

  lvim.builtin.telescope = {
    ---@usage disable telescope completely [not recommended]
    active = true,
    on_config_done = nil,
  }

  local ok, actions = pcall(require, "telescope.actions")
  if not ok then
    return
  end

  lvim.builtin.telescope = vim.tbl_extend("force", lvim.builtin.telescope, {
    defaults = {
      vimgrep_arguments = M.rg_arguments,
      layout_config = {
        width = 0.9,
        prompt_position = "bottom",
        horizontal = { mirror = false, width = 0.95 },
        vertical = { mirror = false, width = 0.85 },
      },
      file_ignore_patterns = {
        "**/yarn.lock",
        "**/node_modules/**",
        "**/package-lock.json",
        "**/.git",
        "**/LICENSE",
        "**/license",
      },
      mappings = {
        i = {
          ["<C-e>"] = actions.cycle_previewers_next,
          ["<C-r>"] = actions.cycle_previewers_prev,
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-c>"] = actions.close,
          ["<C-j>"] = actions.cycle_history_next,
          ["<C-k>"] = actions.cycle_history_prev,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<CR>"] = actions.select_default,
        },
        n = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        },
      },
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      path_display = {},
      winblend = 0,
      -- border = {},
      -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      prompt_prefix = " ",
      selection_caret = " ",
      entry_prefix = "  ",
    },
    pickers = {
      -- Your special builtin config goes in here
      buffers = {
        sort_lastused = true,
        theme = "dropdown",
        previewer = false,
        layout_config = {
          width = 0.5,
          height = 0.25,
          prompt_position = "bottom",
        },
        mappings = {
          i = { ["<c-d>"] = "delete_buffer" },
          n = { ["<c-d>"] = require("telescope.actions").delete_buffer },
        },
      },
      find_files = {
        theme = "dropdown",
        hidden = true,
        find_command = { "fd", "--type=file", "--hidden", "--ignore-case", "--exclude", ".git/" },
        previewer = false,
        shorten_path = false,
        layout_config = {
          width = 0.5,
          height = 0.5,
          prompt_position = "bottom",
        },
      },
      live_grep = {
        -- @usage don't include the filename in the search results
        only_sort_text = true,
      },
      grep_string = {
        -- @usage don't include the filename in the search results
        only_sort_text = true,
      },
      current_buffer_fuzzy_find = {
        theme = "dropdown",
        layout_config = {
          width = 0.5,
          height = 0.5,
          prompt_position = "bottom",
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
    },
  })
end

function M.setup()
  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"
  local actions = require "telescope.actions"

  lvim.builtin.telescope = vim.tbl_extend("force", {
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    file_sorter = sorters.get_fuzzy_file,
    generic_sorter = sorters.get_generic_fuzzy_sorter,
    ---@usage Mappings are fully customizable. Many familiar mapping patterns are setup as defaults.
  }, lvim.builtin.telescope)

  local telescope = require "telescope"
  telescope.setup(lvim.builtin.telescope)

  if lvim.builtin.project.active then
    pcall(function()
      require("telescope").load_extension "projects"
    end)
  end

  if lvim.builtin.notify.active then
    pcall(function()
      require("telescope").load_extension "notify"
    end)
  end

  if lvim.builtin.telescope.on_config_done then
    lvim.builtin.telescope.on_config_done(telescope)
  end

  if lvim.builtin.telescope.extensions and lvim.builtin.telescope.extensions.fzf then
    pcall(function()
      require("telescope").load_extension "fzf"
    end)
  end

  local custom_extensions = { "find_terminals" }

  for _, value in ipairs(custom_extensions) do
    require("telescope").load_extension(value)
  end
end

return M
