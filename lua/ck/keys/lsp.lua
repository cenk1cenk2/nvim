local M = {}

---@param bufnr number
function M.load(bufnr)
  require("ck.setup").init({
    keymaps = {
      {
        "K",
        function()
          nvim.lsp.fn.hover()
        end,
        desc = "hover",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "gd",
        function()
          nvim.lsp.fn.definition()
        end,
        desc = "go to definition",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "gD",
        function()
          nvim.lsp.fn.declaration()
        end,
        desc = "go to declaration",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "gr",
        function()
          nvim.lsp.fn.references()
        end,
        desc = "go to references",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "gt",
        function()
          nvim.lsp.fn.implementation()
        end,
        desc = "go to implementation",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "go",
        function()
          nvim.lsp.fn.signature_help()
        end,
        desc = "show signature help",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "gl",
        function()
          nvim.lsp.fn.show_line_diagnostics()
        end,
        desc = "show line diagnostics",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
      {
        "gh",
        function()
          nvim.lsp.fn.code_action()
        end,
        desc = "code action",
        mode = { "n", "v", "x" },
        buffer = bufnr,
      },
    },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ "q" }),
          function()
            nvim.lsp.fn.fix_current()
          end,
          desc = "fix current",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "c" }),
          function()
            nvim.lsp.fn.incoming_calls()
          end,
          desc = "incoming calls",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "C" }),
          function()
            nvim.lsp.fn.outgoing_calls()
          end,
          desc = "outgoing calls",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "d" }),
          function()
            nvim.lsp.fn.document_diagnostics()
          end,
          desc = "document diagnostics",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "D" }),
          function()
            nvim.lsp.fn.workspace_diagnostics()
          end,
          desc = "workspace diagnostics",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "f" }),
          function()
            nvim.lsp.fn.format()
          end,
          desc = "format buffer",
          mode = { "n", "v" },
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "F" }),
          function()
            require("ck.lsp.format").toggle_format_on_save()
          end,
          desc = "toggle autoformat",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "g" }),
          function()
            vim.cmd([[LspOrganizeImports]])
          end,
          desc = "organize imports",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "G" }),
          function()
            vim.cmd([[LspAddMissingImports]])
          end,
          desc = "add all missing imports",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "i" }),
          function()
            vim.cmd([[LspInfo]])
          end,
          desc = "lsp info",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "m" }),
          function()
            vim.cmd([[LspRenameFile]])
          end,
          desc = "rename file with lsp",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "h" }),
          function()
            vim.cmd([[LspImportAll]])
          end,
          desc = "import all missing",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "H" }),
          function()
            vim.cmd([[LspImportCurrent]])
          end,
          desc = "import current missing",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "n" }),
          function()
            nvim.lsp.fn.jump({ count = 1, severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } })
          end,
          desc = "next diagnostic (error, warn)",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "N" }),
          function()
            nvim.lsp.fn.jump({ count = 1, severity = { vim.diagnostic.severity.INFO, vim.diagnostic.severity.HINT } })
          end,
          desc = "next diagnostic (info, hint)",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "p" }),
          function()
            nvim.lsp.fn.jump({ count = -1, severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN } })
          end,
          desc = "prev diagnostic (error, warn)",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "P" }),
          function()
            nvim.lsp.fn.jump({ count = -1, severity = { vim.diagnostic.severity.INFO, vim.diagnostic.severity.HINT } })
          end,
          desc = "prev diagnostic (info, hint)",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "l" }),
          function()
            nvim.lsp.fn.codelens()
          end,
          desc = "codelens",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "r" }),
          function()
            nvim.lsp.fn.rename()
          end,
          desc = "rename item under cursor",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "q" }),
          function()
            nvim.lsp.fn.diagonistics_set_loclist()
          end,
          desc = "set location list",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "s" }),
          function()
            nvim.lsp.fn.document_symbols()
          end,
          desc = "document symbols",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "S" }),
          function()
            nvim.lsp.fn.workspace_symbols()
          end,
          desc = "workspace symbols",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "t" }),
          function()
            nvim.lsp.fn.toggle_inlay_hints()
          end,
          desc = "toggle inlay hints",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "R" }),
          function()
            nvim.lsp.fn.reset_diagnostics()
          end,
          desc = "reset diagnostics",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "Q" }),
          group = "restart",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "Q", "Q" }),
          function()
            nvim.lsp.fn.restart_lsp()
          end,
          desc = "restart currently active LSPs for this buffer",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "Q", "q" }),
          function()
            nvim.lsp.fn.restart_lsp({})
          end,
          desc = "restart currently active LSPs",
          buffer = bufnr,
        },
        {
          fn.wk_keystroke({ categories.LSP, "?" }),
          group = "logs",
        },
        {
          fn.wk_keystroke({ categories.LSP, "?", "o" }),
          function()
            nvim.fn.toggle_log_view(vim.lsp.get_log_path())
          end,
          desc = "view lsp log",
        },
        {
          fn.wk_keystroke({ categories.LSP, "?", "e" }),
          function()
            vim.cmd(("edit %s"):format(vim.lsp.get_log_path()))
          end,
          desc = "open the lsp logfile",
        },
        {
          fn.wk_keystroke({ categories.LSP, "?", "l" }),
          function()
            vim.ui.select(require("ck.log").levels, {
              prompt = "LSP Log Level",
            }, function(level)
              if not level then
                return
              end

              nvim.lsp.fn.set_log_level(level)
            end)
          end,
          desc = "set lsp log level",
        },
      }
    end,
  })
end

return M
