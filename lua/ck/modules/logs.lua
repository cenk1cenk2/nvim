local M = {}

function M.setup()
  require("ck.setup").init({
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
            nvim.fn.toggle_log_view(require("ck.log").get_path())
          end,
          desc = "view default log",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "D" }),
          function()
            vim.cmd(("edit %s"):format(require("ck.log").get_path()))
          end,
          desc = "open the default logfile",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "l" }),
          function()
            nvim.fn.toggle_log_view(vim.lsp.get_log_path())
          end,
          desc = "view lsp log",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "L" }),
          function()
            vim.cmd(("edit %s"):format(vim.lsp.get_log_path()))
          end,
          desc = "open the lsp logfile",
        },
        {
          fn.wk_keystroke({ categories.LOGS, "n" }),
          function()
            nvim.fn.toggle_log_view(os.getenv("NVIM_LOG_FILE"))
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