-- https://github.com/folke/edgy.nvim
local M = {}

M.name = "folke/edgy.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/edgy.nvim",
        event = "VeryLazy",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "edgy",
      })
    end,
    setup = function()
      ---@type Edgy.Config
      return {
        left = {},
        right = {},
        bottom = {
          {
            ft = "qf",
            title = "QuickFix",
          },
          {
            ft = "help",
            size = {
              height = function()
                if vim.o.lines < 60 then
                  return 0.35
                end

                return 35
              end,
            },
            -- only show help buffers
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
        },

        ---@type table<Edgy.Pos, {size:integer, wo?:vim.wo}>
        options = {
          left = {
            size = function()
              if vim.o.columns < 180 then
                return 0.2
              end

              return 50
            end,
          },
          bottom = {
            size = function()
              if vim.o.lines < 60 then
                return 0.15
              end

              return 15
            end,
          },
          right = {
            size = function()
              if vim.o.columns < 180 then
                return 0.2
              end

              return 50
            end,
          },
          top = {
            size = function()
              if vim.o.lines < 60 then
                return 0.15
              end

              return 15
            end,
          },
        },
        -- edgebar animations
        animate = {
          enabled = false,
          fps = 120, -- frames per second
          cps = 120, -- cells per second
          on_begin = function()
            vim.g.minianimate_disable = true
          end,
          on_end = function()
            vim.g.minianimate_disable = false
          end,
          -- Spinner for pinned views that are loading.
          -- if you have noice.nvim installed, you can use any spinner from it, like:
          -- spinner = require("noice.util.spinners").spinners.circleFull,
          spinner = {
            frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
            interval = 80,
          },
        },
        -- enable this to exit Neovim when only edgy windows are left
        exit_when_last = false,
        -- global window options for edgebar windows
        ---@type vim.wo
        wo = {
          -- Setting to `true`, will add an edgy winbar.
          -- Setting to `false`, won't set any winbar.
          -- Setting to a string, will set the winbar to that string.
          winbar = false,
          winfixwidth = true,
          winfixheight = false,
          winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
          spell = false,
          signcolumn = "no",
        },
        -- buffer-local keymaps to be added to edgebar buffers.
        -- Existing buffer-local keymaps will never be overridden.
        -- Set to false to disable a builtin.
        ---@type table<string, fun(win:Edgy.Window)|false>
        keys = {
          -- close window
          ["q"] = function(win)
            win:close()
          end,
          -- hide window
          ["<c-q>"] = function(win)
            win:hide()
          end,
          -- close sidebar
          ["Q"] = function(win)
            win.view.edgebar:close()
          end,
          -- next open window
          ["]w"] = function(win)
            win:next({ visible = true, focus = true })
          end,
          -- previous open window
          ["[w"] = function(win)
            win:prev({ visible = true, focus = true })
          end,
          -- next loaded window
          ["]W"] = function(win)
            win:next({ pinned = false, focus = true })
          end,
          -- prev loaded window
          ["[W"] = function(win)
            win:prev({ pinned = false, focus = true })
          end,
          -- increase width
          ["<C-M-h>"] = function(win)
            win:resize("width", 5)
          end,
          -- decrease width
          ["<C-M-l>"] = function(win)
            win:resize("width", -5)
          end,
          -- increase height
          ["<C-M-k>"] = function(win)
            win:resize("height", 5)
          end,
          -- decrease height
          ["<C-M-j>"] = function(win)
            win:resize("height", -2)
          end,
          -- reset all custom sizing
          ["<c-w>="] = function(win)
            win.view.edgebar:equalize()
          end,
        },
        icons = {
          closed = nvim.ui.icons.ui.ChevronShortRight,
          open = nvim.ui.icons.ui.ChevronShortDown,
        },
      }
    end,
    on_setup = function(c)
      require("edgy").setup(c)
    end,
  })
end

return M
