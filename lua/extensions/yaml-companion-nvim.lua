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
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["F"] = {
            ["y"] = {
              function()
                require("telescope").extensions.yaml_schema.yaml_schema()
              end,
              "select yaml schema",
            },
          },
        },
      }
    end,
  })
end

return M
