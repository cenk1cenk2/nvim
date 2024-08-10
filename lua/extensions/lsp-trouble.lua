-- https://github.com/folke/trouble.nvim
local M = {}

M.name = "folke/trouble.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "folke/lsp-trouble.nvim",
        cmd = { "Trouble" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "trouble",
      })

      lvim.lsp.wrapper.document_diagnostics = function()
        require("trouble").toggle({
          mode = "diagnostics",
          filter = {
            buf = 0,
            -- severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
          },
        })
      end

      lvim.lsp.wrapper.workspace_diagnostics = function()
        require("trouble").toggle({
          mode = "diagnostics",
          filter = {
            severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
          },
        })
      end
    end,
    setup = function()
      return {
        debug = false,
        auto_close = false, -- auto close when there are no items
        auto_open = false, -- auto open when there are items
        auto_preview = false, -- automatically open preview when on an item
        auto_refresh = true, -- auto refresh when open
        focus = false, -- Focus the window when opened
        restore = true, -- restores the last location in the list when opening
        follow = true, -- Follow the current item
        indent_guides = true, -- show indent guides
        max_items = 200, -- limit number of items that can be displayed per section
        multiline = true, -- render multi-line messages
        pinned = false, -- When pinned, the opened trouble window will be bound to the current buffer
        ---@type trouble.Window.opts
        win = {}, -- window options for the results window. Can be a split or a floating window.
        -- Window options for the preview window. Can be a split, floating window,
        -- or `main` to show the preview in the main editor window.
        ---@type trouble.Window.opts
        preview = { type = "main" },
        -- Key mappings can be set to the name of a builtin action,
        -- or you can define your own custom action.
        ---@type table<string, string|trouble.Action>
        keys = {
          ["?"] = "help",
          r = "refresh",
          R = "toggle_refresh",
          q = "close",
          o = "jump_close",
          ["<esc>"] = "cancel",
          ["<cr>"] = "jump",
          ["<2-leftmouse>"] = "jump",
          ["x"] = "jump_split",
          ["v"] = "jump_vsplit",
          -- go down to next item (accepts count)
          -- j = "next",
          ["}"] = "next",
          ["]]"] = "next",
          -- go up to prev item (accepts count)
          -- k = "prev",
          ["{"] = "prev",
          ["[["] = "prev",
          i = "inspect",
          p = "preview",
          P = "toggle_preview",
          zo = "fold_open",
          zO = "fold_open_recursive",
          zc = "fold_close",
          zC = "fold_close_recursive",
          za = "fold_toggle",
          zA = "fold_toggle_recursive",
          zm = "fold_more",
          zM = "fold_close_all",
          zr = "fold_reduce",
          zR = "fold_open_all",
          zx = "fold_update",
          zX = "fold_update_all",
          zn = "fold_disable",
          zN = "fold_enable",
          zi = "fold_toggle_enable",
        },
      }
    end,
    on_setup = function(config)
      require("trouble").setup(config.setup)
    end,
    autocmds = function()
      return {
        -- https://github.com/folke/trouble.nvim/blob/main/docs/examples.md
        -- {
        --   event = { "QuickFixCmdPost" },
        --   group = "__extensions",
        --   callback = function()
        --     vim.cmd([[Trouble qflist open]])
        --   end,
        -- },
      }
    end,
  })
end

return M
