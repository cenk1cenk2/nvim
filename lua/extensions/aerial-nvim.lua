-- https://github.com/stevearc/aerial.nvim
local M = {}

local extension_name = "aerial_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "stevearc/aerial.nvim",
        config = function()
          require("utils.setup").packer_config "aerial_nvim"
        end,
        disable = not config.active,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes { "aerial" }
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
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
        default_direction = "prefer_right",

        -- Determines where the aerial window will be opened
        --   edge   - open aerial at the far right/left of the editor
        --   window - open aerial to the right/left of the current window
        placement = "window",
      },
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
    },
    on_setup = function(config)
      require("aerial").setup(config.setup)
    end,
    on_done = function(config)
      config.inject.telescope.load_extension "aerial"
      config.inject.telescope.setup {
        extensions = {
          aerial = {
            -- Display symbols as <root>.<parent>.<symbol>
            show_nesting = true,
          },
        },
      }

      lvim.lsp_wrapper.lsp_document_symbols = function()
        vim.cmd "Telescope aerial"
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
