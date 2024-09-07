-- https://github.com/ruslan-korneev/youtrack.nvim
local M = {}

M.name = "cenk1cenk2/youtrack.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/youtrack.nvim",
        build = { "make" },
        -- dir = "~/development/youtrack-nvim",
        dependencies = {
          -- https://github.com/MunifTanjim/nui.nvim
          "MunifTanjim/nui.nvim",
          -- "grapp-dev/nui-components.nvim",
          "grapp-dev/nui-components.nvim",
        },
      }
    end,
    setup = function()
      ---@type youtrack.Config
      return {
        url = vim.env["YOUTRACK_URL"],
        token = vim.env["YOUTRACK_TOKEN"],
        issues = {
          queries = {
            {
              name = "assigned to me",
              query = "for: me #Unresolved",
            },
          },
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
