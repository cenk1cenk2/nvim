-- https://github.com/ruslan-korneev/youtrack.nvim
local M = {}

M.name = "cenk1cenk2/youtrack.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/youtrack.nvim",
        -- dir = "~/development/youtrack.nvim",
        build = { "make" },
        dependencies = {
          -- https://github.com/MunifTanjim/nui.nvim
          "MunifTanjim/nui.nvim",
          -- https://github.com/grapp-dev/nui-components.nvim
          "grapp-dev/nui-components.nvim",
        },
      }
    end,
    setup = function()
      ---@type youtrack.Config
      return {
        log_level = require("ck.log"):to_nvim_level(),
        -- log_level = vim.log.levels.DEBUG,
        url = vim.env["YOUTRACK_URL"],
        token = vim.env["YOUTRACK_TOKEN"],
        queries = {},
        issues = {
          fields = { "State", "Type", "Priority", "Subsystem", "Estimation", "Spent time", "Timer" },
        },
        issue = {},
      }
    end,
    on_setup = function(c)
      require("youtrack").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.ISSUES, "f" }),
          function()
            require("youtrack").get_queries()
          end,
          desc = "get youtrack saved queries",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "i" }),
          function()
            require("youtrack").get_issues()
          end,
          desc = "get youtrack issues",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "t" }),
          function()
            require("youtrack").get_issue()
          end,
          desc = "toggle last opened issue",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "Q" }),
          function()
            require("youtrack").reset_last_issue()
          end,
          desc = "reset last issue",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "l" }),
          function()
            require("youtrack").get_issues({ query = "#Unresolved sort by: updated" })
          end,
          desc = "youtrack query: Unresolved [#Unresolved sort by: updated]",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "L" }),
          function()
            require("youtrack").get_issues({ query = "sort by: updated" })
          end,
          desc = "youtrack query: Recents [sort by: updated]",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "b" }),
          function()
            require("youtrack").get_agiles()
          end,
          desc = "get youtrack boards",
        },
        {
          fn.wk_keystroke({ categories.ISSUES, "c" }),
          function()
            require("youtrack").create_issue()
          end,
          desc = "create youtrack issue",
        },
      }
    end,
  })
end

return M
