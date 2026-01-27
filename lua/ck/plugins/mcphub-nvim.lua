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
        keys = { "<Space>c" },
        cmd = { "MCPHub" },
        -- event = { "VeryLazy" },
      }
    end,
    setup = function()
      ---@type MCPHub.Config
      return {
        log = {
          level = require("ck.log"):to_nvim_level(),
          to_file = false,
          file_path = join_paths(vim.fn.stdpath("cache"), "mcphub.log"),
          prefix = "MCPHub",
        },
        config = join_paths(get_config_dir(), "utils/mcphub/servers.json"),
        port = 37373,
        mcp_request_timeout = 600000,
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
              accept = ".", -- Accept current change
              reject = ",", -- Reject current change
              next = "n", -- Next diff
              prev = "p", -- Previous diff
              accept_all = "ga", -- Accept all remaining changes
              reject_all = "gr", -- Reject all remaining changes
            },
          },
        },
        workspace = {
          enabled = "always",
          look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json", "mcp.json", ".mcp.json" },
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

      M.load_prompts(mcphub)
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

---Load a prompt from the prompts directory
---@param name string The base name of the prompt (e.g., "prompts-assistant")
---@return table|nil metadata The loaded metadata or nil if not found
---@return string|nil content The markdown content or nil if not found
---@return string|nil error Error message if loading failed
function M.load_prompt(name)
  local prompts_dir = join_paths(get_config_dir(), "utils", "claude", "prompts")

  local json_path = vim.fs.joinpath(prompts_dir, name .. ".json")
  local md_path = vim.fs.joinpath(prompts_dir, name .. ".md")

  if vim.fn.filereadable(json_path) == 0 then
    return nil, nil, string.format("JSON metadata file not found: %s", json_path)
  end

  if vim.fn.filereadable(md_path) == 0 then
    return nil, nil, string.format("Markdown content file not found: %s", md_path)
  end

  local json_content = vim.fn.readfile(json_path)
  local ok, metadata = pcall(vim.json.decode, table.concat(json_content, "\n"))
  if not ok then
    return nil, nil, string.format("Failed to parse JSON metadata: %s", metadata)
  end

  local md_content = vim.fn.readfile(md_path)
  local content = table.concat(md_content, "\n")

  return metadata, content, nil
end

---Load all prompts and register them with mcphub
---@param mcphub table The mcphub module
function M.load_prompts(mcphub)
  local async = require("plenary.async")

  async.run(function()
    local config_dir = vim.fn.stdpath("config")
    local prompts_dir = vim.fs.joinpath(config_dir, "utils", "claude", "prompts")

    local json_files = vim.fn.glob(vim.fs.joinpath(prompts_dir, "prompts-*.json"), false, true)

    for _, json_path in ipairs(json_files) do
      local prompt_name = vim.fn.fnamemodify(json_path, ":t:r")

      local metadata, content, err = M.load_prompt(prompt_name)
      if err then
        error(string.format("Failed to load prompt '%s': %s", prompt_name, err), vim.log.levels.ERROR)
      elseif not metadata or not content then
        error(string.format("No metadata found for prompt '%s'", prompt_name), vim.log.levels.ERROR)
      end

      mcphub.add_prompt(metadata.group, {
        name = metadata.name,
        description = metadata.description,
        arguments = metadata.arguments or {},
        handler = function(_, res)
          -- return res:system():text(content):user():llm():text(metadata.response):send()
          return res:text(content .. "\n---\n\n"):user():send()
        end,
      })
    end
  end, nil)
end

return M
