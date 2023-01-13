-- https://github.com/stevearc/aerial.nvim
local M = {}

local extension_name = "aerial_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "aerial",
      })
    end,
    inject_to_configure = function()
      return {
        telescope = require("telescope"),
      }
    end,
    setup = {
      -- Priority list of preferred backends for aerial.
      -- This can be a filetype map (see :help aerial-filetype-map)
      backends = { "lsp", "treesitter", "markdown" },
      layout = {
        -- These control the width of the aerial window.
        -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a list of mixed types.
        -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
        max_width = { 50, 0.2 },
        width = nil,
        min_width = 50,

        -- Determines the default direction to open the aerial window. The 'prefer'
        -- options will open the window in the other direction *if* there is a
        -- different buffer in the way of the preferred direction
        -- Enum: prefer_right, prefer_left, right, left, float
        default_direction = "right",

        -- Determines where the aerial window will be opened
        --   edge   - open aerial at the far right/left of the editor
        --   window - open aerial to the right/left of the current window
        placement = "edge",
      },

      attach_mode = "global",

      highlight_on_jump = false,
      -- Show box drawing characters for the tree hierarchy
      show_guides = true,
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", ":AerialPrev<CR>", { silent = true, buffer = bufnr })
        vim.keymap.set("n", "}", ":AerialNext<CR>", { silent = true, buffer = bufnr })
        -- Jump up the tree with '[[' or ']]'
        vim.keymap.set("n", "[[", ":AerialPrevUp<CR>", { silent = true, buffer = bufnr })
        vim.keymap.set("n", "]]", ":AerialNextUp<CR>", { silent = true, buffer = bufnr })
      end,
      -- A list of all symbols to display. Set to false to display all symbols.
      -- This can be a filetype map (see :help aerial-filetype-map)
      -- To see all available values, see :help SymbolKind
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
        "Constant",
        "Variable",
      },

      -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts.
      -- Additionally, if it is a string that matches "aerial.<name>",
      -- it will use the function at require("aerial.action").<name>
      -- Set to `false` to remove a keymap
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["q"] = "actions.close",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["zr"] = "actions.tree_increase_fold_level",
        ["zR"] = "actions.tree_open_all",
        ["zm"] = "actions.tree_decrease_fold_level",
        ["zM"] = "actions.tree_close_all",
        ["zx"] = "actions.tree_sync_folds",
        ["zX"] = "actions.tree_sync_folds",
      },
    },
    on_setup = function(config)
      require("aerial").setup(config.setup)
    end,
    on_done = function(config)
      config.inject.telescope.load_extension("aerial")
      config.inject.telescope.setup({
        extensions = {
          aerial = {
            -- Display symbols as <root>.<parent>.<symbol>
            show_nesting = true,
          },
        },
      })

      lvim.lsp.wrapper.lsp_document_symbols = function()
        vim.cmd("Telescope aerial")
      end
    end,
    wk = function(_, categories)
      return {
        [categories.LSP] = {
          o = { ":AerialToggle!<CR>", "toggle outline" },
        },
      }
    end,
  })
end

return M
