-- https://github.com/someone-stole-my-name/yaml-companion.nvim
local M = {}

local extension_name = "yaml_companion_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        -- "someone-stole-my-name/yaml-companion.nvim",
        "cenk1cenk2/yaml-companion.nvim",
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
                      name = "schema",
                      ["f"] = {
                        function()
                          return require("telescope").extensions.yaml_schema.yaml_schema()
                        end,
                        "select yaml schema",
                      },
                      ["p"] = {
                        function()
                          local result = require("yaml-companion").get_buf_schema(0).result

                          if not result or not result[1] then
                            require("lvim.core.log"):warn("No schema found.")
                            return
                          end

                          vim.api.nvim_put({ ("# yaml-language-server: $schema=%s"):format(result[1].uri) }, "l", false, true)
                        end,
                        "print yaml schema",
                      },
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
