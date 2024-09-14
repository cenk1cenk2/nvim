-- https://github.com/cenk1cenk2/jq.nvim
local M = {}

M.name = "https://github.com/cenk1cenk2/jq.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/jq.nvim",
        -- dir = "~/development/jq.nvim",
        dependencies = {
          -- https://github.com/nvim-lua/plenary.nvim
          "nvim-lua/plenary.nvim",
          -- https://github.com/MunifTanjim/nui.nvim
          "MunifTanjim/nui.nvim",
          -- https://github.com/grapp-dev/nui-components.nvim
          "grapp-dev/nui-components.nvim",
        },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(c)
      require("jq").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "j" }),
          function()
            require("jq").run({
              toggle = true,
              commands = {
                { command = "jq", filetype = "json" },
              },
              arguments = "-r",
            })
          end,
          desc = "run jq",
        },
        {
          fn.wk_keystroke({ categories.RUN, "J" }),
          function()
            require("jq").run({
              toggle = true,
              commands = {
                { command = "yq", filetype = "json" },
              },
              arguments = "-r",
            })
          end,
          desc = "run yq",
        },
      }
    end,
  })
end

return M
