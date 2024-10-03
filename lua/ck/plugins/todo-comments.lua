-- https://github.com/folke/todo-comments.nvim
local M = {}

M.name = "folke/todo-comments.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/todo-comments.nvim",
        event = "BufReadPost",
        cmd = { "TodoTelescope" },
      }
    end,
    setup = function()
      return {
        {
          signs = true, -- show icons in the signs column
          -- keywords recognized as todo comments
          keywords = {
            FIX = {
              icon = nvim.ui.icons.diagnostics.Debug, -- icon used for the sign, and in search results
              color = "error", -- can be a hex color, or a named color (see below)
              alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
              -- signs = false, -- configure signs for some keywords individually
            },
            TODO = { icon = nvim.ui.icons.misc.Watch, color = "info" },
            HACK = { icon = nvim.ui.icons.misc.Squirrel, color = "warning" },
            WARN = { icon = nvim.ui.icons.diagnostics.Warning, color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = nvim.ui.icons.diagnostics.Trace, alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = nvim.ui.icons.ui.Note, color = "hint", alt = { "INFO" } },
          },
          -- highlighting of the line containing the todo comment
          -- * before: highlights before the keyword (typically comment characters)
          -- * keyword: highlights of the keyword
          -- * after: highlights after the keyword (todo text)
          highlight = {
            before = "", -- "fg" or "bg" or empty
            keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
            after = "fg", -- "fg" or "bg" or empty
          },
          -- list of named colors where we try to extract the guifg from the
          -- list of highlight groups or use the hex color if hl not found as a fallback
          colors = {
            error = { "LspDiagnosticsDefaultError", "ErrorMsg" },
            warning = { "LspDiagnosticsDefaultWarning", "WarningMsg" },
            info = { "LspDiagnosticsDefaultInformation" },
            hint = { "LspDiagnosticsDefaultHint" },
            default = { "Identifier" },
          },
          -- regex that will be used to match keywords.
          -- don't replace the (KEYWORDS) placeholder
          pattern = "@?(KEYWORDS):",
          -- pattern = "(KEYWORDS)", -- match without the extra colon. You'll likely get false positives
          -- pattern = "-- (KEYWORDS):", -- only match in lua comments
        },
      }
    end,
    on_setup = function(c)
      require("todo-comments").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.FIND, "c" }),
          ":TodoTelescope<CR>",
          desc = "todo comments",
        },
      }
    end,
  })
end

return M
