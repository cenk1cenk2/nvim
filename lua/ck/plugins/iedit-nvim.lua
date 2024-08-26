-- https://github.com/altermo/iedit.nvim
local M = {}

local log = require("ck.log")

M.name = "altermo/iedit.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "altermo/iedit.nvim",
      }
    end,
    setup = function()
      return {
        select = {
          map = {
            q = { "done" },
            ["<Esc>"] = { "select", "done" },
            ["<CR>"] = { "toggle" },
            n = { "toggle", "next" },
            p = { "toggle", "prev" },
            N = { "next" },
            P = { "prev" },
            a = { "all" },
            --Mapping to use while in selection-mode
            --Possible values are:
            -- • `done` Done with selection
            -- • `next` Go to next occurrence
            -- • `prev` Go to previous occurrence
            -- • `select` Select current
            -- • `unselect` Unselect current
            -- • `toggle` Toggle current
            -- • `all` Select all
          },
          highlight = {
            current = "CurSearch",
            selected = "Search",
          },
        },
        highlight = "IncSearch",
      }
    end,
    on_setup = function(c)
      -- require("iedit").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "i" }),
          function()
            if M.is_active() then
              log:info("Editing stopped.")

              return require("iedit").stop()
            end

            log:info("Editing started.")
            require("iedit").select()
          end,
          desc = "start iedit",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.TASKS, "I" }),
          function()
            log:info("Editing started with selection.")

            require("iedit").select_all()
          end,
          desc = "start iedit select all",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

function M.is_active(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local data = vim.b[bufnr].iedit_data

  return data ~= nil and (type(data) == "table" and vim.tbl_count(data) > 0)
end

return M
