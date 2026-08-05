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
              height = nvim.ui.dimensions.dock("height", "lg"),
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
            size = nvim.ui.dimensions.dock("width", "sm"),
            wo = M.vertical_wo,
          },
          bottom = {
            size = nvim.ui.dimensions.dock("height", "xs"),
            wo = M.horizontal_wo,
          },
          right = {
            size = nvim.ui.dimensions.dock("width", "md"),
            wo = M.vertical_wo,
          },
          top = {
            size = nvim.ui.dimensions.dock("height", "xs"),
            wo = M.horizontal_wo,
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
          -- `winfixwidth` / `winfixheight` are set per position, see `M.vertical_wo`
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
          -- these shadow the global resize keys in `ck.keys.default`, which do
          -- nothing in an edgebar window, so keep both directions and steps in sync
          -- decrease width
          ["<C-M-h>"] = function(win)
            win:resize("width", -8)
          end,
          -- increase width
          ["<C-M-l>"] = function(win)
            win:resize("width", 8)
          end,
          -- increase height
          ["<C-M-j>"] = function(win)
            win:resize("height", 4)
          end,
          -- decrease height
          ["<C-M-k>"] = function(win)
            win:resize("height", -4)
          end,
          -- reset all custom sizing
          ["<c-w>="] = function(win)
            win.view.edgebar:equalize()
          end,
          ["<c-w>m"] = function(win)
            local dim = win.view.edgebar.vertical and "width" or "height"
            if vim.w[win.win]["edgy_" .. dim] then
              win.view.edgebar:equalize()
            else
              win:resize(dim, 999)
            end
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
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = "WinClosed",
          group = "_edgy_keep_main_window",
          -- edgy replaces the last main window from its own `WinClosed` handler,
          -- but the window being closed is still listed while that runs, so the
          -- check passes and the edgebars end up holding the screen alone. Run it
          -- again once the close has settled.
          callback = function()
            vim.schedule(function()
              if vim.v.exiting == vim.NIL then
                require("edgy.editor").check_main()
              end
            end)
          end,
        },
      }
    end,
  })
end

-- A dock pins the axis it is docked on and lets the other follow the layout. edgy
-- only offers one global `wo`, which cannot be right for both orientations, so the
-- pair is declared per position instead. Whichever axis is left floating makes the
-- dock the nearest donor for a resize on a neighbouring window, which is why Neovim
-- pins `winfixheight` on quickfix windows and why edgy's global default undoing it
-- let `:resize` eat the quickfix instead of taking rows from its siblings.
---@type vim.wo
M.vertical_wo = {
  winfixwidth = true,
  winfixheight = false,
}

---@type vim.wo
M.horizontal_wo = {
  winfixwidth = false,
  winfixheight = true,
}

return M
