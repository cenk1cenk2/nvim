-- https://github.com/folke/todo-comments.nvim
local M = {}

local extension_name = "todo_comments"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "folke/todo-comments.nvim",
        config = function()
          require("utils.setup").plugin_init "todo_comments"
        end,
        enabled = config.active,
      }
    end,
    setup = {
      {
        signs = true, -- show icons in the signs column
        -- keywords recognized as todo comments
        keywords = {
          FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
          },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = "㧸 ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
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
    },
    on_setup = function(config)
      require("todo-comments").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.FIND] = {
          ["c"] = { ":TodoTelescope<CR>", "todo comments" },
        },
      }
    end,
  })
end

return M
