-- https://github.com/nvim-telescope/telescope.nvim
local M = {}

M.name = "nvim-telescope/telescope.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
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

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.document_symbols = function()
        require("telescope.builtin").lsp_document_symbols()
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.implementation = function()
        require("telescope.builtin").lsp_implementations()
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.incoming_calls = function()
        require("telescope.builtin").lsp_incoming_calls()
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.outgoing_calls = function()
        require("telescope.builtin").lsp_outgoing_calls()
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.references = function()
        require("telescope.builtin").lsp_references()
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.workspace_symbols = function()
        require("telescope.builtin").lsp_dynamic_workspace_symbols()
      end
    end,
    setup = function()
      local actions = require("telescope.actions")
      local previewers = require("telescope.previewers")
      local sorters = require("telescope.sorters")

      return {
        defaults = {
          vimgrep_arguments = M.default_rg_arguments,
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
          prompt_prefix = nvim.ui.icons.ui.Telescope .. " ",
          selection_caret = nvim.ui.icons.ui.Forward .. " ",
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
            layout_config = {
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
    on_setup = function(c)
      require("telescope").setup(c)
    end,
    on_done = function(_, fn)
      local telescope = require("telescope")

      local c = fn.get_setup(M.name)

      if c.extensions and c.extensions.fzf then
        telescope.load_extension("fzf")
      end
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ "p" }),
          function()
            M.find_project_files()
          end,
          desc = "find file [project]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ "P" }),
          function()
            M.find_project_files({
              no_ignore = true,
            })
          end,
          desc = "find file [all]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ "o" }),
          function()
            require("telescope.builtin").buffers()
          end,
          desc = "open buffers",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ "O" }),
          function()
            require("telescope.builtin").oldfiles()
          end,
          desc = "search file history",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.FIND, ":" }),
          function()
            require("telescope.builtin").command_history()
          end,
          desc = "search command history",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.FIND, ";" }),
          function()
            require("telescope.builtin").commands()
          end,
          desc = "search available commands",
        },
        {
          fn.wk_keystroke({ categories.FIND, "A" }),
          function()
            require("telescope.builtin").builtin()
          end,
          desc = "telescope builtins",
        },
        {
          fn.wk_keystroke({ categories.FIND, "F" }),
          function()
            require("telescope.builtin").builtin(require("telescope.themes").get_dropdown({ previewer = false }))
          end,
          desc = "telescope list builtin finders",
        },
        {
          fn.wk_keystroke({ categories.FIND, "j" }),
          function()
            require("telescope.builtin").jumplist()
          end,
          desc = "list jumps",
        },
        {
          fn.wk_keystroke({ categories.FIND, "S" }),
          function()
            require("telescope.builtin").spell_suggest()
          end,
          desc = "search spell suggestions",
        },

        {
          fn.wk_keystroke({ categories.FIND, "q" }),
          function()
            require("telescope.builtin").quickfixhistory()
          end,
          desc = "quickfix history",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "f" }),
          function()
            require("telescope.builtin").filetypes()
          end,
          desc = "select from filetypes",
        },
        {
          fn.wk_keystroke({ categories.GIT, "f" }),
          function()
            require("telescope.builtin").git_status()
          end,
          desc = "git status",
        },
        {
          fn.wk_keystroke({ categories.GIT, "F" }),
          function()
            require("telescope.builtin").git_files()
          end,
          desc = "list git tracked files",
        },
        {
          fn.wk_keystroke({ categories.FIND, "k" }),
          function()
            require("telescope.builtin").keymaps()
          end,
          desc = "list keymaps",
        },

        -- searches

        {
          fn.wk_keystroke({ categories.FIND, "f" }),
          function()
            require("telescope.builtin").resume()
          end,
          desc = "resume last search",
        },
        {
          fn.wk_keystroke({ categories.FIND, "a" }),
          function()
            M.set_rg_arguments()
          end,
          desc = "set ripgrep arguments",
        },
        {
          fn.wk_keystroke({ categories.FIND, "b" }),
          function()
            M.rg_grep_buffer_fuzzy()
          end,
          desc = "grep fuzzy current buffer",
        },
        {
          fn.wk_keystroke({ categories.FIND, "B" }),
          function()
            M.rg_grep_buffer()
          end,
          desc = "grep current buffer",
        },
        {
          fn.wk_keystroke({ categories.FIND, "d" }),
          function()
            M.rg_dirty()
          end,
          desc = "grep dirty",
        },
        {
          fn.wk_keystroke({ categories.FIND, "D" }),
          function()
            M.rg_dirty({
              grep_open_files = true,
            })
          end,
          desc = "grep dirty for open buffers",
        },
        {
          fn.wk_keystroke({ categories.FIND, "g" }),
          function()
            require("telescope.builtin").grep_string({
              additional_args = M.extend_rg_arguments(),
            })
          end,
          desc = "grep under cursor",
        },
        {
          fn.wk_keystroke({ categories.FIND, "G" }),
          function()
            require("telescope.builtin").grep_string({
              grep_open_files = true,
              additional_args = M.extend_rg_arguments(),
            })
          end,
          desc = "grep under cursor for open buffers",
        },
        {
          fn.wk_keystroke({ categories.FIND, "r" }),
          function()
            require("telescope.builtin").live_grep({
              additional_args = M.extend_rg_arguments(),
            })
          end,
          desc = "grep with regexp",
        },
        {
          fn.wk_keystroke({ categories.FIND, "R" }),
          function()
            require("telescope.builtin").live_grep({
              grep_open_files = true,
              additional_args = M.extend_rg_arguments(),
            })
          end,
          desc = "grep regexp open buffers",
        },
        {
          fn.wk_keystroke({ categories.FIND, "t" }),
          function()
            M.rg_string()
          end,
          desc = "grep string",
        },
        {
          fn.wk_keystroke({ categories.FIND, "T" }),
          function()
            M.rg_string({
              grep_open_files = true,
              additional_args = M.extend_rg_arguments(),
            })
          end,
          desc = "grep string open buffers",
        },
      }
    end,
  })
end

M.default_rg_arguments = {
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

M.RG_ARGS_ENV_VAR = "RG_ARGS"

function M.extend_rg_arguments(...)
  local target = {}

  if ... and vim.tbl_count(...) > 0 then
    for _, args in ipairs(...) do
      if args then
        if type(args) == "string" then
          args = { args }
        end

        vim.list_extend(target, args)
      end
    end
  end

  local args = vim.env[M.RG_ARGS_ENV_VAR]

  if args == nil or args == "" then
    return target
  end

  local chunks = {}

  for substring in args:gmatch("%S+") do
    table.insert(chunks, substring)
  end

  return vim.list_extend(target, chunks)
end

function M.set_rg_arguments()
  vim.ui.input({
    prompt = "Ripgrep arguments:",
    default = vim.env[M.RG_ARGS_ENV_VAR],
  }, function(val)
    if val == nil then
      val = ""
    end

    vim.env["RG_ARGS"] = vim.fn.expand(tostring(val))
  end)
end

---@module telescope.builtin
---Rip greps with fixed-strings.
---@param options livegrep
---@return unknown
function M.rg_string(options)
  options = options or {}
  return require("telescope.builtin").live_grep(vim.tbl_extend("force", options, {
    additional_args = M.extend_rg_arguments({ "--fixed-strings" }, options.additional_args),
  }))
end

function M.rg_dirty(options)
  options = options or {}
  require("telescope.builtin").grep_string(vim.tbl_extend("force", options or {}, {
    shorten_path = true,
    word_match = "-w",
    search = "",
    additional_args = M.extend_rg_arguments(options.additional_args),
  }))
end

function M.rg_grep_buffer(options)
  options = options or {}
  return require("telescope.builtin").live_grep(vim.tbl_extend("force", options or {}, {
    additional_args = { "--no-ignore" },
    search_dirs = { "%:p" },
    layout_config = {
      prompt_position = "bottom",
    },
  }))
end

function M.rg_grep_buffer_fuzzy(options)
  options = options or {}
  return require("telescope.builtin").current_buffer_fuzzy_find(vim.tbl_extend("force", options or {}, {
    additional_args = { "--no-ignore" },
  }))
end

-- Smartly opens either git_files or find_files, depending on whether the working directory is
-- contained in a Git repo.
function M.find_project_files(options)
  options = options or {}
  -- local ok = pcall(builtin.git_files)

  -- if not ok then
  require("telescope.builtin").find_files(vim.tbl_extend("force", options, { previewer = true }))
  -- end
end

--- Returns the arguments to be passed to telescope.
---@param flags_only boolean Without the first element.
---@param extend? table<string>
---@return table<string>
function nvim.fn.get_telescope_args(flags_only, extend)
  local rg_arguments = vim.deepcopy(M.default_rg_arguments)

  if flags_only then
    table.remove(rg_arguments, 1)
  end

  if extend then
    rg_arguments = M.extend_rg_arguments(rg_arguments)
  end

  return rg_arguments
end

return M
