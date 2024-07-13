-- https://github.com/nvim-telescope/telescope.nvim
local M = {}

local extension_name = "telescope"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-telescope/telescope.nvim",
        dependencies = {
          {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = { "make" },
          },
          {
            "tzachar/fuzzy.nvim",
          },
        },
        cmd = { "Telescope" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "Telescope",
        "TelescopePrompt",
        "TelescopeResults",
      })
    end,
    rg_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob=!.git/",
    },
    setup = function(config)
      local actions = require("telescope.actions")
      local previewers = require("telescope.previewers")
      local sorters = require("telescope.sorters")

      return {
        defaults = {
          vimgrep_arguments = config.rg_arguments,
          find_command = "rg",
          layout_config = {
            bottom_pane = {
              height = 25,
              preview_cutoff = 120,
              prompt_position = "top",
            },
            center = {
              height = 0.5,
              preview_cutoff = 40,
              prompt_position = "top",
              width = 0.5,
            },
            cursor = {
              height = 0.9,
              preview_cutoff = 40,
              width = 0.8,
            },
            horizontal = {
              preview_width = 0.55,
              mirror = true,
              width = 0.9,
              height = 0.9,
              prompt_position = "bottom",
            },
            vertical = {
              mirror = false,
              width = 0.9,
              height = 0.9,
              prompt_position = "bottom",
            },
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
          -- borderchars = { "─", "│", "─", "│", "┍", "┒", "┙", "┕" },
          color_devicons = true,
          use_less = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
          prompt_prefix = lvim.ui.icons.ui.Telescope .. " ",
          selection_caret = lvim.ui.icons.ui.Forward .. " ",
          entry_prefix = "  ",
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
        },
        pickers = {
          -- Your special builtin config goes in here
          buffers = {
            sort_lastused = true,
            theme = "dropdown",
            previewer = true,
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
              height = 0.25,
              prompt_position = "bottom",
            },
          },
          oldfiles = {
            theme = "dropdown",
            layout_config = {
              width = 0.5,
              height = 0.25,
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
            theme = "ivy",
            layout_config = {
              width = 0.75,
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
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        file_sorter = sorters.get_fuzzy_file,
        generic_sorter = sorters.get_generic_fuzzy_sorter,
      }
    end,
    on_setup = function(config)
      require("telescope").setup(config.setup)
    end,
    on_done = function(config)
      local telescope = require("telescope")

      if config.current_setup.extensions and config.current_setup.extensions.fzf then
        telescope.load_extension("fzf")
      end
    end,
    define_global_fn = function(config)
      return {
        get_telescope_rg_arguments = function(flags_only)
          local rg_arguments = vim.deepcopy(config.rg_arguments)

          if flags_only then
            table.remove(rg_arguments, 1)
          end

          return rg_arguments
        end,
      }
    end,
    wk = function(_, categories, fn)
      local finders = require("modules.telescope")

      return {
        {
          fn.wk_keystroke({ "p" }),
          function()
            finders.find_project_files()
          end,
          desc = "find file",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ "o" }),
          function()
            vim.cmd([[Telescope buffers]])
          end,
          desc = "open buffers",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ "O" }),
          function()
            vim.cmd([[Telescope oldfiles]])
          end,
          desc = "search file history",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, ":" }),
          function()
            vim.cmd([[Telescope command_history]])
          end,
          desc = "search command history",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.FIND, ":" }),
          function()
            vim.cmd([[Telescope commands]])
          end,
          desc = "search available commands",
        },
        {
          fn.wk_keystroke({ categories.FIND, "A" }),
          function()
            vim.cmd([[Telescope builtin]])
          end,
          desc = "telescope list builtin finders",
        },
        {
          fn.wk_keystroke({ categories.FIND, "b" }),
          function()
            finders.rg_current_buffer_fuzzy_find()
          end,
          desc = "search current buffer fuzzy",
        },
        {
          fn.wk_keystroke({ categories.FIND, "B" }),
          function()
            finders.rg_grep_buffer()
          end,
          desc = "search current buffer grep",
        },
        {
          fn.wk_keystroke({ categories.FIND, "d" }),
          function()
            finders.rg_dirty()
          end,
          desc = "dirty fuzzy grep",
        },
        {
          fn.wk_keystroke({ categories.FIND, "f" }),
          function()
            vim.cmd([[Telescope resume]])
          end,
          desc = "resume last search",
        },
        {
          fn.wk_keystroke({ categories.FIND, "g" }),
          function()
            vim.cmd([[Telescope grep_string]])
          end,
          desc = "grep string under cursor",
        },
        {
          fn.wk_keystroke({ categories.FIND, "j" }),
          function()
            vim.cmd([[Telescope jumplist]])
          end,
          desc = "list jumps",
        },
        {
          fn.wk_keystroke({ categories.FIND, "s" }),
          function()
            vim.cmd([[Telescope spell_suggest]])
          end,
          desc = "search spell suggestions",
        },
        {
          fn.wk_keystroke({ categories.FIND, "r" }),
          function()
            finders.rg_interactive()
          end,
          desc = "ripgrep interactive",
        },
        {
          fn.wk_keystroke({ categories.FIND, "R" }),
          function()
            vim.cmd([[Telescope live_grep]])
          end,
          desc = "grep with regexp",
        },
        {
          fn.wk_keystroke({ categories.FIND, "t" }),
          function()
            finders.rg_string()
          end,
          desc = "grep string",
        },
        {
          fn.wk_keystroke({ categories.FIND, "T" }),
          function()
            finders.rg_string({
              additional_args = { grep_open_files = true },
            })
          end,
          desc = "grep string open buffers",
        },
        {
          fn.wk_keystroke({ categories.FIND, "q" }),
          function()
            vim.cmd([[Telescope quickfixhistory]])
          end,
          desc = "quickfix history",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "f" }),
          function()
            vim.cmd([[Telescope filetypes]])
          end,
          desc = "select from filetypes",
        },
        {
          fn.wk_keystroke({ categories.GIT, "f" }),
          function()
            vim.cmd([[Telescope git_status]])
          end,
          desc = "git status",
        },
        {
          fn.wk_keystroke({ categories.GIT, "F" }),
          function()
            vim.cmd([[Telescope git_files]])
          end,
          desc = "list git tracked files",
        },
        {
          fn.wk_keystroke({ categories.NEOVIM, "k" }),
          function()
            vim.cmd([[Telescope keymaps]])
          end,
          desc = "list keymaps",
        },
      }
    end,
  })
end

return M
