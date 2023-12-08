-- https://github.com/folke/edgy.nvim
local M = {}

local extension_name = "edgy_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
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
      return {
        bottom = {
          -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
          {
            ft = "toggleterm",
            -- exclude floating windows
            filter = function(buf, win)
              return vim.api.nvim_win_get_config(win).relative == ""
            end,
          },
          "Trouble",
          { ft = "qf", title = "QuickFix" },
          {
            ft = "help",
            size = { height = 20 },
            -- only show help buffers
            filter = function(buf)
              return vim.bo[buf].buftype == "help"
            end,
          },
          {
            ft = "dbout",
            title = "DadBod-Out",
          },
        },
        right = {
          {
            ft = "spectre_panel",
            size = { width = 150 },
          },
          {
            title = "Neo-Tree Git",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "git_status"
            end,
          },
          {
            title = "Neo-Tree Buffers",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "buffers"
            end,
          },
          {
            title = "Neo-Tree Outline",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "document_symbols"
            end,
          },
        },
        left = {
          -- Neo-tree filesystem always takes half the screen height
          {
            title = "Neo-Tree",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem" or vim.b[buf].neo_tree_source == "remote"
            end,
          },

          {
            ft = "dbui",
            title = "DadBod-UI",
          },
        },

        ---@type table<Edgy.Pos, {size:integer, wo?:vim.wo}>
        options = {
          left = { size = 50 },
          bottom = { size = 20 },
          right = { size = 50 },
          top = { size = 20 },
        },
        -- edgebar animations
        animate = {
          enabled = false,
          fps = 100, -- frames per second
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
          ["<c-w>>"] = function(win)
            win:resize("width", 2)
          end,
          -- decrease width
          ["<c-w><lt>"] = function(win)
            win:resize("width", -2)
          end,
          -- increase height
          ["<c-w>+"] = function(win)
            win:resize("height", 2)
          end,
          -- decrease height
          ["<c-w>-"] = function(win)
            win:resize("height", -2)
          end,
          -- reset all custom sizing
          ["<c-w>="] = function(win)
            win.view.edgebar:equalize()
          end,
        },
        icons = {
          closed = lvim.ui.icons.ui.ChevronShortRight,
          open = lvim.ui.icons.ui.ChevronShortDown,
        },
      }
    end,
    on_setup = function(config)
      require("edgy").setup(config.setup)
    end,
  })
end

return M
