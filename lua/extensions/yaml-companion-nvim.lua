-- https://github.com/someone-stole-my-name/yaml-companion.nvim
local M = {}

local extension_name = "yaml_companion_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "someone-stole-my-name/yaml-companion.nvim",
        ft = { "yaml", "helm" },
      }
    end,
    on_done = function()
      require("telescope").load_extension("yaml_schema")
    end,
    autocmds = function()
      local categories = require("keys.wk").CATEGORIES

      return {
        {
          "FileType",
          {
            group = "__extensions",
            pattern = { "yaml", "helm" },
            callback = function(event)
              require("utils.setup").load_wk({
                {
                  { "n" },
                  [categories.ACTIONS] = {
                    ["F"] = {
                      function()
                        return require("telescope").extensions.yaml_schema.yaml_schema()
                      end,
                      "select yaml schema",
                    },
                  },
                },
              }, {
                buffer = event.buf,
              })
            end,
          },
        },
      }
    end,
  })
end

return M
