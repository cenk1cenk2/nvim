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
        keys = { "<leader>c" },
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

      M.register_agent_skills()
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
        {
          fn.wk_keystroke({ categories.COPILOT, "H" }),
          function()
            vim.ui.open("http://localhost:37777")
          end,
          desc = "toggle claude memory",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

function M.agent_skills_dir()
  return join_paths(get_config_dir(), "utils/agents/skills")
end

---@param content string
---@param fallback_name string
---@return {name:string, description:string, body:string, frontmatter:table<string,string>}
function M.parse_skill_markdown(content, fallback_name)
  local lines = vim.split(content, "\n", { plain = true })
  local frontmatter = {}
  local body_start = 1

  if lines[1] == "---" then
    local end_idx = nil
    for i = 2, #lines do
      if lines[i] == "---" then
        end_idx = i
        break
      end

      local key, value = lines[i]:match("^([%w_%-]+):%s*(.*)$")
      if key then
        value = value:gsub("^['\"]", ""):gsub("['\"]$", "")
        frontmatter[key] = value
      end
    end

    if end_idx ~= nil then
      body_start = end_idx + 1
    end
  end

  local body_lines = {}
  for i = body_start, #lines do
    table.insert(body_lines, lines[i])
  end

  local name = frontmatter.name or fallback_name
  local description = frontmatter.description or ("Guidance for " .. name)
  local body = vim.trim(table.concat(body_lines, "\n"))

  return {
    name = name,
    description = description,
    body = body,
    frontmatter = frontmatter,
  }
end

---@param dir string|nil
---@return table[]
function M.load_agent_skills(dir)
  local skills = {}
  local skill_dir = dir or M.agent_skills_dir()

  if vim.fn.isdirectory(skill_dir) == 0 then
    return skills
  end

  local files = vim.fn.glob(join_paths(skill_dir, "*/SKILL.md"), false, true)
  table.sort(files)

  for _, file in ipairs(files) do
    local file_content = vim.fn.readfile(file)
    if file_content and #file_content > 0 then
      local fallback_name = vim.fn.fnamemodify(file, ":h:t")
      local parsed = M.parse_skill_markdown(table.concat(file_content, "\n"), fallback_name)
      parsed.file_path = file
      if parsed.name ~= "" and parsed.description ~= "" and parsed.body ~= "" then
        table.insert(skills, parsed)
      end
    end
  end

  return skills
end

function M.register_agent_skills()
  if M._agent_skills_registered then
    return
  end

  local mcphub = require("mcphub")
  local skills = M.load_agent_skills()

  local function xml_escape(value)
    if value == nil then
      return ""
    end

    local s = tostring(value)
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    s = s:gsub('"', "&quot;")
    s = s:gsub("'", "&apos;")
    return s
  end

  ---@param skill {name:string, description:string, body:string, frontmatter:table<string,string>}
  ---@param request string
  ---@return string
  local function build_skill_user_payload(skill)
    local lines = {
      "````xml",
      "<Skill>",
      "  <Name>" .. xml_escape(skill.name) .. "</Name>",
      "  <Description>" .. xml_escape(skill.description) .. "</Description>",
      "  <Instructions>",
      skill.body,
      "  </Instructions>",
    }

    local metadata_keys = vim.tbl_keys(skill.frontmatter or {})
    table.sort(metadata_keys)
    if #metadata_keys > 0 then
      table.insert(lines, "  <Metadata>")
      for _, key in ipairs(metadata_keys) do
        table.insert(lines, string.format('    <Field key="%s">%s</Field>', xml_escape(key), xml_escape(skill.frontmatter[key])))
      end
      table.insert(lines, "  </Metadata>")
    end

    table.insert(lines, "</Skill>")
    table.insert(lines, "````")
    table.insert(lines, "\n")

    return table.concat(lines, "\n")
  end

  for _, skill in ipairs(skills) do
    mcphub.add_prompt("skills", {
      name = skill.name,
      description = skill.description,
      handler = function(req, res)
        local file_content = vim.fn.readfile(skill.file_path)
        if file_content and #file_content > 0 then
          local fresh = M.parse_skill_markdown(table.concat(file_content, "\n"), skill.name)

          return res:user():text(build_skill_user_payload(fresh)):send()
        end

        return res:user():text(build_skill_user_payload(skill)):send()
      end,
    })
  end

  M._agent_skills_registered = true
end

return M
