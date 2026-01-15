-- https://github.com/ravitemer/mcphub.nvim
local M = {}

M.name = "ravitemer/mcphub.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        -- "ravitemer/mcphub.nvim",
        -- TODO: POINT TO ORIGINAL WHEN FORK MERGES OR IF MERGES?
        "cenk1cenk2/mcphub.nvim",
        branch = "patch-1",
        build = { "bundled_scripts.lua" },
        -- dir = "~/development/mcphub.nvim",
        cmd = { "MCPHub" },
      }
    end,
    setup = function()
      return {

        log = {
          level = vim.log.levels.DEBUG,
          to_file = true,
          file_path = "/tmp/mcphub.log",
          prefix = "MCPHub",
        },
        config = join_paths(get_config_dir(), "utils/mcphub/servers.json"),
        port = 37373,
        proxy = true,
        global_env = function(context)
          local env = {
            "DBUS_SESSION_BUS_ADDRESS",
          }

          -- Always set workspace variables (even when not in workspace mode)
          env.WORKSPACE_ROOT = context.workspace_root or vim.fn.getcwd()
          env.WORKSPACE_PORT = tostring(context.port)
          env.NVIM = vim.v.servername

          env.CONFIG_FILES = table.concat(context.config_files, ":")

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
          enabled = "always",
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
    on_done = function()
      -- Add native browser tool
      local mcphub = require("mcphub")
      mcphub.add_tool("browser", {
        name = "open_in_browser",
        description = "Open a URL in the default web browser using vim.ui.open()",
        inputSchema = {
          type = "object",
          properties = {
            url = {
              type = "string",
              description = "The URL to open in the browser (must be a valid http:// or https:// URL)",
            },
          },
          required = { "url" },
        },
        handler = function(req, res)
          local url = req.params.url

          -- Validate URL format
          if not url:match("^https?://") then
            return res:error("Invalid URL format. URL must start with http:// or https://")
          end

          -- Open the URL using vim.ui.open
          local success, err = pcall(vim.ui.open, url)

          if not success then
            return res:error("Failed to open URL: " .. tostring(err))
          end

          return res:text("Successfully opened URL in browser: " .. url):send()
        end,
      })
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
