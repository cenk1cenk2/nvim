-- https://github.com/someone-stole-my-name/yaml-companion.nvim
-- https://github.com/cenk1cenk2/yaml-companion.nvim
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
    autocmds = function(_, fn)
      return {
        {
          event = "FileType",
          group = "__extensions",
          pattern = { "yaml", "helm" },
          callback = function(event)
            require("utils.setup").load_wk({
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F" }),
                group = "schema",
              },
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "f" }),
                function()
                  return require("telescope").extensions.yaml_schema.yaml_schema()
                end,
                desc = "select yaml schema",
                buffer = event.buf,
              },
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "p" }),
                function()
                  local result = require("yaml-companion").get_buf_schema(0).result

                  if not result or not result[1] then
                    require("lvim.core.log"):warn("No schema found.")
                    return
                  end

                  vim.api.nvim_put({ ("# yaml-language-server: $schema=%s"):format(result[1].uri) }, "l", false, true)
                end,
                desc = "print yaml schema",
                buffer = event.buf,
              },
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "k" }),
                function()
                  vim.ui.input({
                    prompt = "Kubernetes version;",
                    default = require("yaml-companion").ctx.kubernetes_version,
                  }, function(version)
                    if not version then
                      return
                    end

                    local result = require("yaml-companion").set_version("kubernetes", version)
                  end)
                end,
                desc = "set kubernetes version",
                buffer = event.buf,
              },
            })
          end,
        },
      }
    end,
  })
end

return M
