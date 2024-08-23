-- https://github.com/amrbashir/nvim-docs-view
local M = {}

M.name = "amrbashir/nvim-docs-view"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
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
    on_setup = function(c)
      require("docs-view").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.LSP, "v" }),
          function()
            vim.cmd([[DocsViewToggle]])
          end,
          desc = "toggle documentation",
        },
      }
    end,
    autocmds = function()
      return {
        require("modules.autocmds").set_view_buffer({ "nvim-docs-view" }),
        require("modules.autocmds").q_close_autocmd({ "nvim-docs-view" }),
      }
    end,
  })
end

return M
