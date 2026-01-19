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
      ---@type jq.Config
      return {
        log_level = require("ck.log"):to_nvim_level(),
      }
    end,
    on_setup = function(c)
      require("jq").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "j", "j" }),
          function()
            require("jq").run({
              toggle = true,
              commands = {
                { command = "jq", filetype = "json" },
              },
              arguments = "-r",
            })
          end,
          desc = "run jq for buffer",
        },
        {
          fn.wk_keystroke({ categories.RUN, "j", "j" }),
          function()
            require("jq").run_visual({
              toggle = true,
              commands = {
                { command = "jq", filetype = "json" },
              },
              arguments = "-r",
            })
          end,
          desc = "run jq for visual",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.RUN, "j", "J" }),
          function()
            require("jq").run({
              toggle = true,
              commands = {
                { command = "jq", filetype = "json" },
              },
              arguments = "-r",
              clipboard = true,
            })
          end,
          desc = "run jq for clipboard",
        },
        {
          fn.wk_keystroke({ categories.RUN, "j", "y" }),
          function()
            require("jq").run({
              toggle = true,
              commands = {
                { command = "yq", filetype = "yaml" },
              },
              arguments = "-P -o yaml -r",
            })
          end,
          desc = "run yq for buffer",
        },
        {
          fn.wk_keystroke({ categories.RUN, "j", "y" }),
          function()
            require("jq").run_visual({
              toggle = true,
              commands = {
                { command = "yq", filetype = "yaml" },
              },
              arguments = "-P -o yaml -r",
            })
          end,
          desc = "run yq for visual",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.RUN, "j", "Y" }),
          function()
            require("jq").run({
              toggle = true,
              commands = {
                { command = "yq", filetype = "yaml" },
              },
              arguments = "-P -o yaml -r",
              clipboard = true,
            })
          end,
          desc = "run yq for clipboard",
        },
      }
    end,
  })
end

return M
