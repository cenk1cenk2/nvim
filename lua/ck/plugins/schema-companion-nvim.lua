-- https://github.com/cenk1cenk2/schema-companion.nvim
local M = {}

M.name = "cenk1cenk2/schema-companion.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/schema-companion.nvim",
        -- dir = "~/development/schema-companion.nvim",
        ft = { "yaml", "helm", "yaml.*", "json*", "toml" },
      }
    end,
    setup = function()
      ---@type schema_companion.Config
      return {
        -- log_level = vim.log.levels.DEBUG,
        log_level = require("ck.log"):to_nvim_level(),
      }
    end,
    on_setup = function(c)
      require("schema-companion").setup(c)
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").init_with({ "FileType" }, { "yaml", "helm", "yaml.*", "json*", "toml" }, function(event)
          return {
            keymaps = function(_, fn)
              ---@type KeymapMappings
              return {
                {
                  fn.local_keystroke({ "s" }),
                  function()
                    return require("schema-companion").select_matching_schema()
                  end,
                  desc = "select from matching schema",
                  buffer = event.buf,
                },
                {
                  fn.local_keystroke({ "f" }),
                  function()
                    return require("schema-companion").select_schema()
                  end,
                  desc = "select schema",
                  buffer = event.buf,
                },
                {
                  fn.local_keystroke({ "R" }),
                  function()
                    require("schema-companion").match()
                  end,
                  desc = "rematch schema",
                  buffer = event.buf,
                },
                {
                  fn.local_keystroke({ "k" }),
                  function()
                    require("schema-companion").sources.matchers.kubernetes.change_version()
                  end,
                  desc = "set kubernetes version",
                  buffer = event.buf,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

return M
