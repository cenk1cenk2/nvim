-- https://github.com/neoclide/coc.nvim
local M = {}

local extension_name = "coc"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "neoclide/coc.nvim",
        branch = "release",
        cmd = { "CocList", "CocCommand" },
      }
    end,
    legacy_setup = {
      coc_start_at_startup = true,
      coc_suggest_disable = 1,
      coc_global_extensions = {
        "coc-lists",
        "coc-marketplace",
        "coc-gitignore",
        "coc-gist",
      },
    },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.GIT, "g" }),
          group = "gists",
        },
        {
          fn.wk_keystroke({ categories.GIT, "g", "f" }),
          function()
            vim.cmd([[CocList gist]])
          end,
          desc = "list gists",
        },
        {
          fn.wk_keystroke({ categories.GIT, "g", "p" }),
          function()
            vim.cmd([[CocList gist.create]])
          end,
          desc = "post new gist",
        },
        {
          fn.wk_keystroke({ categories.GIT, "g", "U" }),
          function()
            vim.cmd([[CocList gist.update]])
          end,
          desc = "update current gist",
        },
      }
    end,
  })
end

return M
