local M = {}

function M.setup()
  require("utils.setup").init({
    name = "logs",
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.LOGS, "l" }),
          group = "logs",
          mode = { "n", "v" },
        },

        {
          fn.wk_keystroke({ categories.LOGS, "d" }),
          function()
            lvim.fn.toggle_log_view(require("lvim.core.log").get_path())
          end,
          desc = "view default log",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "D" }),
          function()
            vim.fn.execute("edit " .. require("lvim.core.log").get_path())
          end,
          desc = "open the default logfile",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "l" }),
          function()
            lvim.fn.toggle_log_view(vim.lsp.get_log_path())
          end,
          desc = "view lsp log",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "L" }),
          function()
            vim.fn.execute("edit " .. vim.lsp.get_log_path())
          end,
          desc = "open the lsp logfile",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "n" }),
          function()
            lvim.fn.toggle_log_view(os.getenv("NVIM_LOG_FILE"))
          end,
          desc = "view neovim log",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "N" }),
          ":edit $NVIM_LOG_FILE<CR>",
          desc = "open the neovim logfile",
        },
      }
    end,
  })
end

return M
