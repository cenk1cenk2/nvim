-- https://github.com/cenk1cenk2/yaml-companion.nvim
local M = {}

local extension_name = "yaml_companion_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        -- dir = "~/development/yaml-companion.nvim",
        "cenk1cenk2/yaml-companion.nvim",
        ft = { "yaml", "helm" },
      }
    end,
    setup = function()
      return {
        log_level = "debug",
        formatting = false,
        -- Built in file matchers
        matchers = {
          require("yaml-companion.matchers.kubernetes").setup({ version = "master" }),
        },
        -- Additional schemas available in Telescope picker
        schemas = {
          {
            name = "ArgoCD",
            uri = "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json",
          },
          {
            name = "Kubernetes master",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
          },
          {
            name = "Kubernetes v1.27",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.16-standalone-strict/all.json",
          },
          {
            name = "Kubernetes v1.28",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.12-standalone-strict/all.json",
          },
          {
            name = "Kubernetes v1.29",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.7-standalone-strict/all.json",
          },
          {
            name = "Kubernetes v1.30",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.3-standalone-strict/all.json",
          },
          {
            name = "Gitlab CI",
            uri = "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json",
          },
        },
      }
    end,
    on_setup = function(config)
      require("yaml-companion").setup(config.setup)
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
                  require("yaml-companion.matchers.kubernetes").change_version()
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
