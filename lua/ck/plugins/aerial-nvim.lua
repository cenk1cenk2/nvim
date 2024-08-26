-- https://github.com/stevearc/aerial.nvim
local M = {}

M.name = "stevearc/aerial.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
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
    setup = function()
      return {
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
        -- Array Boolean Class Constant Constructor Enum EnumMember Event Field File Function Interface Key Method Module Namespace Null Number Object Operator Package Property String Struct TypeParameter Variable
        filter_kind = {
          ["_"] = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
            "EnumMember",
            -- "Constant",
            -- "Variable",
          },
          ["yaml"] = {
            "Array",
            "Boolean",
            "Class",
            "Constant",
            "Constructor",
            "Enum",
            "EnumMember",
            "Event",
            "Field",
            "File",
            "Function",
            "Interface",
            "Key",
            "Method",
            "Module",
            "Namespace",
            "Null",
            "Number",
            "Object",
            "Operator",
            "Package",
            "Property",
            "String",
            "Struct",
            "TypeParameter",
            "Variable",
          },
          ["json"] = {
            "Array",
            "Boolean",
            "Class",
            "Constant",
            "Constructor",
            "Enum",
            "EnumMember",
            "Event",
            "Field",
            "File",
            "Function",
            "Interface",
            "Key",
            "Method",
            "Module",
            "Namespace",
            "Null",
            "Number",
            "Object",
            "Operator",
            "Package",
            "Property",
            "String",
            "Struct",
            "TypeParameter",
            "Variable",
          },
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
      }
    end,
    on_setup = function(c)
      require("aerial").setup(c)
    end,
    on_done = function()
      local telescope = require("telescope")
      telescope.load_extension("aerial")

      telescope.setup({
        extensions = {
          aerial = {
            theme = "dropdown",
            layout_config = {
              width = 0.5,
              height = 0.25,
              prompt_position = "bottom",
            },
            -- Display symbols as <root>.<parent>.<symbol>
            show_nesting = {
              ["_"] = false, -- This key will be the default
              json = true, -- You can set the option for specific filetypes
              yaml = true,
            },
          },
        },
      })

      nvim.lsp.fn.lsp_document_symbols = function()
        require("telescope").extensions.aerial.aerial()
      end
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(event)
          return {
            wk = function(_, categories, fn)
              return {
                {
                  fn.wk_keystroke({ categories.LSP, "o" }),
                  function()
                    vim.cmd([[AerialToggle!]])
                  end,
                  desc = "toggle outline",
                  buffer = event.buf,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

return M
