-- https://github.com/amrbashir/nvim-docs-view
local M = {}

M.name = "amrbashir/nvim-docs-view"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "amrbashir/nvim-docs-view",
        cmd = { "DocsViewToggle" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "nvim-docs-view",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.bottom, {
          {
            ft = "nvim-docs-view",
            title = "LSP Documentation",
            size = {
              height = function()
                if vim.o.lines < 60 then
                  return 0.2
                end

                return 25
              end,
            },
          },
        })

        return c
      end)
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
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(bufnr)
          return {
            wk = function(_, categories, fn)
              ---@type WKMappings
              return {
                {
                  fn.wk_keystroke({ categories.LSP, "v" }),
                  function()
                    vim.cmd([[DocsViewToggle]])
                  end,
                  desc = "toggle documentation",
                  buffer = bufnr,
                },
              }
            end,
          }
        end),

        require("ck.modules.autocmds").set_view_buffer({ "nvim-docs-view" }),
        require("ck.modules.autocmds").q_close_autocmd({ "nvim-docs-view" }),
      }
    end,
  })
end

return M
