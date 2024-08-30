-- https://github.com/yetone/avante.nvim
local M = {}

M.name = "yetone/avante.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "yetone/avante.nvim",
        dependencies = {
          { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
          { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "AvanteInput",
        "Avante",
      })

      -- fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
      --   vim.list_extend(c.right, {
      --     {
      --       title = "Avante",
      --       ft = "Avante",
      --       size = {
      --         width = function()
      --           if vim.o.columns < 180 then
      --             return 0.5
      --           end
      --
      --           return 120
      --         end,
      --       },
      --     },
      --   })
      --
      --   return c
      -- end)
    end,
    setup = function()
      return {
        provider = "copilot",
      }
    end,
    on_setup = function(c)
      require("avante").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("avante.api").ask()
          end,
          desc = "toggle chat [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "e" }),
          function()
            require("avante.api").edit()
          end,
          desc = "edit [avante]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            require("avante.api").refresh()
          end,
          desc = "refresh [avante]",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({
          "Avante",
          "AvanteInput",
        }),
      }
    end,
  })
end

return M
