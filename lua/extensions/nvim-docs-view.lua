-- https://github.com/amrbashir/nvim-docs-view
local M = {}

local extension_name = "nvim_docs_view"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "amrbashir/nvim-docs-view",
        cmd = { "DocsViewToggle" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "nvim-docs-view",
      })
    end,
    setup = function()
      return {
        position = "bottom",
        width = 75,
        height = 18,
      }
    end,
    on_setup = function(config)
      require("docs-view").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.LSP] = {
          ["v"] = { ":DocsViewToggle<CR>", "toggle documentation" },
        },
      }
    end,
    autocmds = {
      {
        "FileType",
        {
          group = "__nvim_docs_view",
          pattern = "nvim-docs-view",
          command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell nolist nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs=",
        },
      },

      {
        "FileType",
        {
          group = "__nvim_docs_view",
          pattern = "nvim-docs-view",
          command = "nnoremap <silent> <buffer> q :q<CR>",
        },
      },
    },
  })
end

return M
