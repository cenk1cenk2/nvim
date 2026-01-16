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
        -- dir = "~/development/mcphub.nvim",
        branch = "patch-1",
        build = { "bundled_scripts.lua" },
        keys = { { "<Space>c" } },
        cmd = { "MCPHub" },
      }
    end,
    setup = function()
      return {
        log = {
          level = require("ck.log"):to_nvim_level(),
          to_file = false,
          file_path = join_paths(vim.fn.stdpath("cache"), "mcphub.log"),
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
        builtin_tools = {
          edit_file = {
            go_to_origin_on_complete = true, -- Jump back to original file on completion
            keybindings = {
              accept = "<localleader>ca", -- Accept current change
              reject = "<localleader>cr", -- Reject current change
              next = "<localleader>n", -- Next diff
              prev = "<localleader>p", -- Previous diff
              accept_all = "<localleader>aa", -- Accept all remaining changes
              reject_all = "<localleader>ar", -- Reject all remaining changes
            },
          },
        },
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
      mcphub.add_tool("browser", {
        name = "open_in_obsidian",
        description = "Open Obsidian note using vim.ui.open()",
        inputSchema = {
          type = "object",
          properties = {
            url = {
              type = "string",
              description = "The URL to open in the obsidian (must be a valid obsidian://)",
            },
          },
          required = { "url" },
        },
        handler = function(req, res)
          local url = req.params.url

          -- Validate URL format
          if not url:match("^obsidian?://") then
            return res:error("Invalid URL format. URL must start with obsidian://")
          end

          -- Open the URL using vim.ui.open
          local success, err = pcall(vim.ui.open, url)

          if not success then
            return res:error("Failed to open in Obsidian: " .. tostring(err))
          end

          return res:text("Successfully opened in Obsidian: " .. url):send()
        end,
      })

      mcphub.add_prompt("prompts", {
        name = "assistant",
        description = "Plan and track changes through an assistant.",
        arguments = {
          {
            name = "topic",
            description = "Brief description of the topic or changes to be made to plan first.",
            required = true,
          },
        },
        handler = function(req, res)
          local topic = req.params.topic

          local system_prompt = [[
- We will refine a plan together to do some changes, the implementation might not be exact so we will refine while doing.
- First we will go through what needs to be achieved and what changes we need to make that happen.
- I want you the assistant to keep track of the changes we are doing and propose pitfalls and problems each time prompted.
- Always keep track of the changes through `git` changes and utilizing your available tools to cross things of the initial plan and adjust the plan as we go along.
- Refine your understanding as we go along and the changes evolve, by taking in the inputs about our discussions.
- Use thinking whenever you feel like deviating from the current plan might cause problems and propose solutions.
- Be understanding of the things of the replies but always feel free to question them.]]

          local response = res:system():text(system_prompt)

          response = response:user():text(string.format("Let us start by creating a plan: %s", topic))

          return response:llm():text(string.format("I will suck it up and wait in the sidelines while you do your thing.", topic)):send()
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
