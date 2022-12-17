-- https://github.com/nvim-telescope/telescope.nvim
local M = {}

local extension_name = "telescope"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-telescope/telescope.nvim",
        requires = {
          {
            "nvim-telescope/telescope-fzf-native.nvim",
            run = "make",
          },
          { "tzachar/fuzzy.nvim", requires = { "nvim-telescope/telescope-fzf-native.nvim" } },
        },
        config = function()
          require("utils.setup").packer_config "telescope"
        end,
        disable = not config.active,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes {
        "TelescopePrompt",
        "Telescope",
      }
    end,
    to_inject = function()
      return {
        actions = require "telescope.actions",
        previewers = require "telescope.previewers",
        sorters = require "telescope.sorters",
      }
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
      local actions = config.inject.actions
      local previewers = config.inject.previewers
      local sorters = config.inject.sorters

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
            horizontal = { mirror = true, width = 0.9, height = 0.9, prompt_position = "bottom" },
            vertical = { mirror = false, width = 0.9, height = 0.9, prompt_position = "bottom" },
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
      if lvim.builtin.notify.active then
        pcall(function()
          require("telescope").load_extension "notify"
        end)
      end

      if config.current_setup.extensions and config.current_setup.extensions.fzf then
        pcall(function()
          require("telescope").load_extension "fzf"
        end)
      end
    end,
    define_global_fn = function(config)
      return {
        get_telescope_rg_arguments = function()
          return config.rg_arguments
        end,
      }
    end,
    wk = function(_, categories)
      local custom_finders = require "modules.telescope"

      return {
        ["p"] = {
          function()
            require("lvim.core.telescope.custom-finders").find_project_files()
          end,
          "find file",
        },

        [categories.FIND] = {
          ["."] = { ":Telescope commands<CR>", "search available commands" },
          [":"] = { ":Telescope command_history<CR>", "search command history" },
          A = { ":Telescope builtin<CR>", "telescope list builtin finders" },
          b = { ":Telescope current_buffer_fuzzy_find<CR>", "search current buffer fuzzy" },
          f = { ":Telescope oldfiles<CR>", "search file history" },
          g = { ":Telescope grep_string<CR>", "grep string under cursor" },
          j = { ":Telescope jumplist<CR>", "list jumps" },
          s = { ":Telescope spell_suggest<CR>", "spell suggest" },
          T = { ":Telescope live_grep<CR>", "grep with regexp" },
          B = {
            function()
              custom_finders.rg_grep_buffer()
            end,
            "search current buffer grep",
          },
          r = {
            function()
              custom_finders.rg_interactive()
            end,
            "ripgrep interactive",
          },
          d = {
            function()
              custom_finders.rg_dirty()
            end,
            "dirty fuzzy grep",
          },
          t = {
            function()
              custom_finders.rg_string()
            end,
            "grep string",
          },
        },

        [categories.ACTIONS] = {
          f = { ":Telescope filetypes<CR>", "select from filetypes" },
        },

        [categories.BUFFER] = {
          f = { ":Telescope buffers<CR>", "find buffer" },
        },

        [categories.GIT] = {
          f = { ":Telescope git_status<CR>", "git status" },
          F = { ":Telescope git_files<CR>", "list git tracked files" },
        },

        [categories.GIST] = {
          I = { ":Telescope gh issues<CR>", "github issues" },
          P = { ":Telescope gh pull_request<CR>", "github pull requests" },
        },

        [categories.NEOVIM] = {
          k = { ":Telescope keymaps<CR>", "list keymaps" },
        },
      }
    end,
  })
end

return M
