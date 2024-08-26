-- https://github.com/danymat/neogen
local M = {}

M.name = "danymat/neogen"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "danymat/neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("neogen").setup(c)
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(bufnr)
          return {
            wk = function(_, categories, fn)
              return {
                {
                  fn.wk_keystroke({ categories.LSP, "j" }),
                  function()
                    require("neogen").generate()
                  end,
                  desc = "generate documentation",
                  buffer = bufnr,
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
