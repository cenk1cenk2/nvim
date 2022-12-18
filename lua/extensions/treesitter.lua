-- https://github.com/nvim-treesitter/nvim-treesitter
local M = {}

local extension_name = "treesitter"

local Log = require "lvim.core.log"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
          require("utils.setup").packer_config "treesitter"
        end,
        disable = not config.active,
      }
    end,
    condition = function()
      if #vim.api.nvim_list_uis() == 0 then
        Log:debug "Headless mode detected, skipping running setup for treesitter."

        return false
      end
    end,
    setup = function()
      return {
        ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        ignore_install = {},
        matchup = {
          enable = false, -- mandatory, false will disable the whole extension
          -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
        },
        highlight = {
          enable = true, -- false will disable the whole extension
          additional_vim_regex_highlighting = false,
          disable = { "latex" },
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        indent = { enable = true, disable = { "yaml", "python" } },
        autotag = { enable = true },
        textobjects = {
          swap = {
            enable = false,
            -- swap_next = textobj_swap_keymaps,
          },
          -- move = textobj_move_keymaps,
          select = {
            enable = false,
            -- keymaps = textobj_sel_keymaps,
          },
        },
        textsubjects = { enable = false, keymaps = { ["."] = "textsubjects-smart", [";"] = "textsubjects-big" } },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
          },
        },
        rainbow = {
          enable = true,
          extended_mode = false, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
          max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
          colors = { "#ffd700", "#8bb9dd" },
          disable = lvim.disabled_filetypes,
        },
        refactor = { highlight_current_scope = { enable = false } },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            scope_incremental = "<CR>",
            node_incremental = "<TAB>",
            node_decremental = "<S-TAB>",
          },
        },
      }
    end,
    on_setup = function(config)
      require("nvim-treesitter.configs").setup(config.setup)
    end,
    on_done = function(config)
      if config.setup.context_commentstring and config.setup.context_commentstring.enable then
        lvim.extensions.comment_nvim.to_setup.pre_hook = function(ctx)
          if
            vim.tbl_contains({ "javascript", "typescriptreact", "vue", "svelte" }, function(type)
              return type ~= vim.bo.filetype
            end)
          then
            return
          end

          local U = require "Comment.utils"

          -- Determine whether to use linewise or blockwise commentstring
          local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

          -- Determine the location where to calculate commentstring from
          local location = nil
          if ctx.ctype == U.ctype.blockwise then
            location = require("ts_context_commentstring.utils").get_cursor_location()
          elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
            location = require("ts_context_commentstring.utils").get_visual_start_location()
          end

          return require("ts_context_commentstring.internal").calculate_commentstring {
            key = type,
            location = location,
          }
        end
      end
    end,
    wk = function(_, categories)
      return {
        [categories.TREESITTER] = {
          i = { ":TSConfigInfo<CR>", "treesitter info" },
          -- k = { ":TSHighlightCapturesUnderCursor<CR>", "show treesitter theme color" },
          k = { ":Inspect<CR>", "inspect color scheme" },
          u = { ":TSUpdate<CR>", "update installed treesitter packages" },
          U = { ":TSUninstall all<CR>", "uninstall all treesitter packages" },
          R = { ":TSInstall all<CR>", "reinstall all treesitter packages" },
        },
      }
    end,
  })
end

return M
