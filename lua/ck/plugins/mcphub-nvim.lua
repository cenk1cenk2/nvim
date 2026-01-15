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
        global_env = function(context)
          local env = {
            "DBUS_SESSION_BUS_ADDRESS",
          }

          -- Always set workspace variables (even when not in workspace mode)
          env.WORKSPACE_ROOT = context.workspace_root or vim.fn.getcwd()
          vim.env.WORKSPACE_ROOT = env.WORKSPACE_ROOT
          env.WORKSPACE_PORT = tostring(context.port)
          vim.env.WORKSPACE_PORT = tostring(context.port)

          env.CONFIG_FILES = table.concat(context.config_files, ":")
          local sockets = vim.fn.serverlist()
          if sockets and #sockets > 0 then
            env.NVIM = sockets[1]
          end

          return env
        end,
        ui = {
          window = {
            width = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            height = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
            relative = "editor",
            zindex = 50,
            border = nvim.ui.border, -- "none", "single", "double", "rounded", "solid", "shadow"
          },
          wo = { -- window-scoped options (vim.wo)
            winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
          },
        },
        builtin_tools = {},
        workspace = {
          enabled = true,
          look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json", "mcp.json" },
          reload_on_dir_changed = true, -- Auto-switch on directory change
          port_range = { min = 40000, max = 41000 }, -- Port range for workspace hubs
          -- Always assign a workspace port (force workspace mode)
        },
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
