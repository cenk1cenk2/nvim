-- https://github.com/nvim-treesitter/nvim-treesitter
local M = {}

local extension_name = "treesitter"

local Log = require("lvim.core.log")

M.parsers_dir = join_paths(get_data_dir(), "parsers")

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-treesitter/nvim-treesitter",
        build = function()
          vim.cmd([[TSUpdate]])
        end,
        event = "BufReadPre",
        cond = function()
          if is_headless() then
            Log:debug("Headless mode detected, skipping running setup for treesitter.")

            return false
          end

          return true
        end,
        dependencies = {
          {
            "JoosepAlviste/nvim-ts-context-commentstring",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            event = "BufReadPost",
          },
          {
            "mrjones2014/nvim-ts-rainbow",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            event = "BufReadPost",
          },
          {
            "windwp/nvim-ts-autotag",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            event = "InsertEnter",
          },
          -- {
          --   "nvim-treesitter/playground",
          --   after = { "nvim-treesitter" },
          -- },
        },
      }
    end,
    configure = function(_, fn)
      fn.append_to_setup("comment_nvim", {
        pre_hook = function(ctx)
          if vim.tbl_contains({ "typescriptreact", "vue", "svelte" }, function(type)
            return type ~= vim.bo.filetype
          end) then
            return
          end

          local U = require("Comment.utils")

          -- Determine whether to use linewise or blockwise commentstring
          local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

          -- Determine the location where to calculate commentstring from
          local location = nil
          if ctx.ctype == U.ctype.blockwise then
            location = require("ts_context_commentstring.utils").get_cursor_location()
          elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
            location = require("ts_context_commentstring.utils").get_visual_start_location()
          end

          return require("ts_context_commentstring.internal").calculate_commentstring({
            key = type,
            location = location,
          })
        end,
      })
    end,
    inject_to_configure = function()
      return {
        parser_config = require("nvim-treesitter.parsers").get_parser_configs(),
        ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername,
      }
    end,
    setup = function()
      vim.opt.runtimepath:prepend(M.parsers_dir)

      return {
        parser_install_dir = M.parsers_dir,
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
        indent = { enable = true, disable = {} },
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
          colors = { lvim.ui.colors.yellow[900], lvim.ui.colors.cyan[900], lvim.ui.colors.orange[900], lvim.ui.colors.blue[900] },
          disable = lvim.disabled_filetypes,
        },
        refactor = { highlight_current_scope = { enable = false } },
        -- https://github.com/nvim-treesitter/nvim-treesitter/issues/4000
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<S-CR>",
            node_decremental = "<BS>",
          },
        },
      }
    end,
    parser_config = {
      -- jinja = {
      --   install_info = {
      --     url = "https://github.com/theHamsta/tree-sitter-jinja2.git",
      --     files = { "src/parser.c" },
      --     generate_requires_npm = false,
      --     requires_generate_from_grammar = false,
      --   },
      --   filetype = "jinja",
      -- },
    },
    ft_to_parser = {
      -- ["jinja"] = "jinja",
    },
    on_setup = function(config)
      require("nvim-treesitter.configs").setup(config.setup)
    end,
    on_done = function(config)
      local parser_config = config.inject.parser_config
      local ft_to_parser = config.inject.ft_to_parser

      for key, value in pairs(config.parser_config) do
        parser_config[key] = value
      end

      for key, value in pairs(config.ft_to_parser) do
        ft_to_parser[key] = value
      end
    end,
    wk = function(_, categories, fn)
      return {
        [categories.TREESITTER] = {
          i = { ":TSConfigInfo<CR>", "treesitter info" },
          k = { ":Inspect<CR>", "inspect color scheme" },
          u = { ":TSUpdate<CR>", "update installed treesitter packages" },
          U = { ":TSUninstall all<CR>", "uninstall all treesitter packages" },
          R = {
            function()
              for _, parser in pairs(fn.get_current_setup(extension_name).ensure_installed) do
                vim.cmd(("TSInstall %s"):format(parser))
              end
            end,
            "reinstall all treesitter packages",
          },
        },
      }
    end,
  })
end

return M
