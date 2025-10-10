-- https://github.com/ravitemer/mcphub.nvim
local M = {}

M.name = "ravitemer/mcphub.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "ravitemer/mcphub.nvim",
        build = "bun add -g mcp-hub@latest",
        cmd = { "MCPHub" },
      }
    end,
    setup = function()
      return {
        config = join_paths(get_config_dir(), "utils/mcphub/servers.json"),
        port = 37373,
      }
    end,
    on_setup = function(config)
      require("mcphub").setup(config)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "h" }),
          function()
            vim.cmd([[MCPHub]])
          end,
          desc = "toggle mcphub",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

return M
