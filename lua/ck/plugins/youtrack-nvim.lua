-- https://github.com/ruslan-korneev/youtrack.nvim
local M = {}

M.name = "cenk1cenk2/youtrack.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
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
      local size = {}
      if vim.o.columns < 180 then
        size.width = 0.95
      end
      if vim.o.lines < 60 then
        size.height = 0.95
      end

      ---@type youtrack.Config
      return {
        url = vim.env["YOUTRACK_URL"],
        token = vim.env["YOUTRACK_TOKEN"],
        queries = {},
        ui = {
          height = size.height,
          width = size.width,
        },
        issues = {
          size = size,
          fields = { "State", "Priority", "Subsystem", "Type", "Estimation", "Spent time", "Timer" },
        },
        issue = {
          size = size,
        },
      }
    end,
    on_setup = function(c)
      require("youtrack").setup(c)
    end,
    wk = function(config, categories, fn)
      return {
        {
          fn.wk_keystroke({ "i" }),
          function()
            require("youtrack").get_issues()
          end,
          desc = "get youtrack issues",
        },
      }
    end,
  })
end

return M
