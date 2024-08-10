-- https://github.com/cenk1cenk2/schema-companion.nvim
local M = {}

M.name = "cenk1cenk2/schema-companion.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "cenk1cenk2/schema-companion.nvim",
        -- dir = "~/development/schema-companion.nvim",
        ft = { "yaml", "helm" },
      }
    end,
    setup = function()
      return {
        log_level = lvim.log.level,
        formatting = false,
        enable_telescope = true,
        -- Built in file matchers
        matchers = {
          require("schema-companion.matchers.kubernetes").setup({ version = "master" }),
        },
        schemas = {
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
      require("schema-companion").setup(config.setup)
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
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "s" }),
                function()
                  return require("telescope").extensions.schema_companion.select_from_matching_schemas()
                end,
                desc = "select from matching schema",
                buffer = event.buf,
              },
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "f" }),
                function()
                  return require("telescope").extensions.schema_companion.select_schema()
                end,
                desc = "select yaml schema",
                buffer = event.buf,
              },
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "p" }),
                function()
                  local result = require("schema-companion.context").get_buffer_schema(0)

                  if not result then
                    require("lvim.core.log"):warn("No schema found.")
                    return
                  end

                  vim.api.nvim_put({ ("# yaml-language-server: $schema=%s"):format(result.uri) }, "l", false, true)
                end,
                desc = "print yaml schema",
                buffer = event.buf,
              },
              {
                fn.wk_keystroke({ fn.get_wk_category("ACTIONS"), "F", "k" }),
                function()
                  require("schema-companion.matchers.kubernetes").change_version()
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
