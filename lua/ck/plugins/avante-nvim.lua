-- https://github.com/yetone/avante.nvim
local M = {}

M.name = "yetone/avante.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "yetone/avante.nvim",
        build = "make",
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
    setup = function(_, fn)
      local categories = fn.get_wk_categories()

      ---@type avante.Config
      return {
        provider = "copilot",
        windows = {
          wrap = true, -- similar to vim.o.wrap
          width = 50, -- default % based on available width
          sidebar_header = {
            rounded = false,
          },
        },
        mappings = {
          ask = fn.wk_keystroke({ categories.COPILOT, "c" }),
          edit = fn.wk_keystroke({ categories.COPILOT, "e" }),
          refresh = fn.wk_keystroke({ categories.COPILOT, "r" }),
          toggle = {
            debug = fn.wk_keystroke({ categories.COPILOT, "A" }),
            hint = fn.wk_keystroke({ categories.COPILOT, "a" }),
          },
        },
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
