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
        branch = "next",
        build = { "bundled_scripts.lua" },
        keys = { "<leader>c" },
        cmd = { "MCPHub" },
        -- event = { "VeryLazy" },
        dependencies = {
          { "georgeharker/mcp-diagnostics.nvim" },
        },
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

      -- Helper: switch to a buffer by path or bufnr, creating if needed
      -- Uses window-picker to find a suitable window, avoiding special windows
      local function switch_to_buffer(path, bufnr)
        local function focus_or_pick(target_buf)
          local wins = vim.fn.win_findbuf(target_buf)
          if #wins > 0 then
            vim.api.nvim_set_current_win(wins[1])

            return
          end

          local win = nvim.fn.pick_window()
          if win then
            vim.api.nvim_set_current_win(win)
          end
          vim.api.nvim_set_current_buf(target_buf)
        end

        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          focus_or_pick(bufnr)

          return
        end

        if path then
          local existing = vim.fn.bufnr(path)
          if existing ~= -1 then
            focus_or_pick(existing)
          else
            local win = nvim.fn.pick_window()
            if win then
              vim.api.nvim_set_current_win(win)
            end
            vim.cmd.edit(vim.fn.fnameescape(path))
          end
        end
      end

      -- Navigation tools for editor control
      mcphub.add_tool("vim", {
        name = "vim_status",
        description = "Get current editor state: cursor position, mode, current file, and open buffers",
        inputSchema = {
          type = "object",
          properties = {},
        },
        handler = function(req, res)
          local info = req.editor_info
          local active = info.last_active

          local buffers = {}
          for _, buf in ipairs(info.buffers) do
            if buf.is_loaded then
              table.insert(buffers, {
                name = buf.filename,
                filetype = buf.filetype,
                modified = buf.is_modified,
                visible = buf.is_visible,
                bufnr = buf.bufnr,
              })
            end
          end

          return res
            :text(vim.json.encode({
              file = active.filename,
              filetype = active.filetype,
              cursor = { line = active.cursor_pos[1], col = active.cursor_pos[2] },
              line_count = active.line_count,
              modified = active.is_modified,
              mode = vim.api.nvim_get_mode().mode,
              buffers = buffers,
            }))
            :send()
        end,
      })

      mcphub.add_tool("vim", {
        name = "vim_file_open",
        description = "Open a file in the editor. Reuses existing buffer if already open. Optionally jump to a line and column.",
        inputSchema = {
          type = "object",
          properties = {
            path = {
              type = "string",
              description = "Absolute file path to open",
            },
            line = {
              type = "number",
              description = "Line number to jump to (1-based, optional)",
            },
            col = {
              type = "number",
              description = "Column number to jump to (0-based, optional)",
            },
          },
          required = { "path" },
        },
        handler = function(req, res)
          local path = req.params.path
          local line = req.params.line
          local col = req.params.col or 0

          vim.schedule(function()
            switch_to_buffer(path)

            if line then
              local buf = vim.api.nvim_get_current_buf()
              local max_lines = vim.api.nvim_buf_line_count(buf)
              line = math.min(line, max_lines)
              vim.api.nvim_win_set_cursor(0, { line, col })
              vim.cmd.normal({ "zz", bang = true })
            end
          end)

          local msg = "Opened " .. path
          if line then
            msg = msg .. " at line " .. line
          end

          return res:text(msg):send()
        end,
      })

      mcphub.add_tool("vim", {
        name = "vim_jump",
        description = "Jump to a specific line and column. Targets current buffer unless path or bufnr is provided.",
        inputSchema = {
          type = "object",
          properties = {
            line = {
              type = "number",
              description = "Line number to jump to (1-based)",
            },
            col = {
              type = "number",
              description = "Column number to jump to (0-based, optional, defaults to 0)",
            },
            path = {
              type = "string",
              description = "File path to target (optional, opens/switches to buffer first)",
            },
            bufnr = {
              type = "number",
              description = "Buffer number to target (optional, alternative to path)",
            },
          },
          required = { "line" },
        },
        handler = function(req, res)
          local line = req.params.line
          local col = req.params.col or 0
          local path = req.params.path
          local bufnr = req.params.bufnr

          vim.schedule(function()
            if path or bufnr then
              switch_to_buffer(path, bufnr)
            end

            local buf = vim.api.nvim_get_current_buf()
            local max_lines = vim.api.nvim_buf_line_count(buf)
            line = math.min(line, max_lines)
            vim.api.nvim_win_set_cursor(0, { line, col })
            vim.cmd.normal({ "zz", bang = true })
          end)

          local target = path or req.editor_info.last_active.filename

          return res:text("Jumped to line " .. line .. " in " .. target):send()
        end,
      })

      mcphub.add_tool("vim", {
        name = "vim_select",
        description = "Visually select a range of lines. Targets current buffer unless path or bufnr is provided.",
        inputSchema = {
          type = "object",
          properties = {
            start_line = {
              type = "number",
              description = "Start line of selection (1-based)",
            },
            end_line = {
              type = "number",
              description = "End line of selection (1-based)",
            },
            path = {
              type = "string",
              description = "File path to target (optional, opens/switches to buffer first)",
            },
            bufnr = {
              type = "number",
              description = "Buffer number to target (optional, alternative to path)",
            },
          },
          required = { "start_line", "end_line" },
        },
        handler = function(req, res)
          local start_line = req.params.start_line
          local end_line = req.params.end_line
          local path = req.params.path
          local bufnr = req.params.bufnr

          vim.schedule(function()
            if path or bufnr then
              switch_to_buffer(path, bufnr)
            end

            local buf = vim.api.nvim_get_current_buf()
            local max_lines = vim.api.nvim_buf_line_count(buf)
            start_line = math.min(start_line, max_lines)
            end_line = math.min(end_line, max_lines)

            vim.api.nvim_win_set_cursor(0, { start_line, 0 })
            vim.cmd.normal({ "V", bang = true })
            vim.api.nvim_win_set_cursor(0, { end_line, 0 })
          end)

          local target = path or req.editor_info.last_active.filename

          return res:text("Selected lines " .. start_line .. "-" .. end_line .. " in " .. target):send()
        end,
      })

      mcphub.add_tool("mcp-diagnostics", {
        name = "lsp_rename",
        description = "Rename a symbol under the cursor using LSP. Optionally navigate to a specific location first.",
        inputSchema = {
          type = "object",
          properties = {
            new_name = {
              type = "string",
              description = "The new name for the symbol",
            },
            path = {
              type = "string",
              description = "File path containing the symbol (optional, uses current buffer if omitted)",
            },
            line = {
              type = "number",
              description = "Line number of the symbol (1-based, optional)",
            },
            col = {
              type = "number",
              description = "Column number of the symbol (0-based, optional)",
            },
          },
          required = { "new_name" },
        },
        handler = function(req, res)
          local new_name = req.params.new_name
          local path = req.params.path
          local line = req.params.line
          local col = req.params.col or 0

          vim.schedule(function()
            if path then
              switch_to_buffer(path)
            end

            if line then
              local buf = vim.api.nvim_get_current_buf()
              local max_lines = vim.api.nvim_buf_line_count(buf)
              line = math.min(line, max_lines)
              vim.api.nvim_win_set_cursor(0, { line, col })
            end

            vim.lsp.buf.rename(new_name)
          end)

          local target = path or req.editor_info.last_active.filename

          return res:text("Renamed symbol to '" .. new_name .. "' in " .. target):send()
        end,
      })

      -- Skills tools — auto-approved MCP tools for reading skills and references
      local skills_dir = M.agent_skills_dir()

      mcphub.add_tool("skills", {
        name = "list_skills",
        description = "List all available skills with their names, descriptions, and invocation mode. [auto] skills can be auto-invoked by the model based on context. [manual] skills require explicit user request.",
        inputSchema = {
          type = "object",
          properties = {},
        },
        handler = function(req, res)
          local skills = M.load_agent_skills()
          local lines = {}
          for _, skill in ipairs(skills) do
            local invokable = skill.frontmatter["disable-model-invocation"] ~= "true"
            local tag = invokable and "[auto]" or "[manual]"
            table.insert(lines, string.format("- %s **%s**: %s", tag, skill.name, skill.description))
          end

          return res:text(table.concat(lines, "\n")):send()
        end,
      })

      mcphub.add_tool("skills", {
        name = "read_skill",
        description = "Read one or more skills by name. Returns full SKILL.md content including frontmatter for each skill.",
        inputSchema = {
          type = "object",
          properties = {
            names = {
              type = "array",
              items = { type = "string" },
              description = "Skill names to read (e.g., ['linear-issue-create', 'obsidian-note']).",
            },
          },
          required = { "names" },
        },
        handler = function(req, res)
          local names = req.params.names
          if not names or #names == 0 then
            return res:error("No skill names provided")
          end

          local results = {}
          local errors = {}
          for _, name in ipairs(names) do
            local skill_path = join_paths(skills_dir, name, "SKILL.md")
            if vim.fn.filereadable(skill_path) == 1 then
              local content = table.concat(vim.fn.readfile(skill_path), "\n")
              table.insert(results, string.format("--- %s ---\n%s", name, content))
            else
              table.insert(errors, name)
            end
          end

          if #errors > 0 then
            table.insert(results, string.format("\n--- NOT FOUND: %s ---", table.concat(errors, ", ")))
          end

          return res:text(table.concat(results, "\n\n")):send()
        end,
      })

      mcphub.add_tool("skills", {
        name = "read_reference",
        description = "Read one or more reference files using relative paths as declared in skill frontmatter. Paths are resolved from the skill's directory.",
        inputSchema = {
          type = "object",
          properties = {
            paths = {
              type = "array",
              items = { type = "string" },
              description = "Relative reference paths exactly as declared in skill frontmatter (e.g., ['../references/slack.md', '../references/plan-mode.md', './references/local.md']).",
            },
            skill = {
              type = "string",
              description = "The skill name whose directory is used to resolve relative paths (e.g., 'linear-issue-create'). Required for correct path resolution.",
            },
          },
          required = { "paths", "skill" },
        },
        handler = function(req, res)
          local paths = req.params.paths
          local skill_name = req.params.skill

          if not paths or #paths == 0 then
            return res:error("No reference paths provided")
          end
          if not skill_name or skill_name == "" then
            return res:error("Skill name is required for resolving relative paths")
          end

          local skill_folder = join_paths(skills_dir, skill_name)
          if vim.fn.isdirectory(skill_folder) ~= 1 then
            return res:error("Skill directory not found: " .. skill_name)
          end

          local results = {}
          local errors = {}
          for _, rel_path in ipairs(paths) do
            local abs_path = vim.fn.resolve(join_paths(skill_folder, vim.trim(rel_path)))
            if vim.fn.filereadable(abs_path) == 1 then
              local basename = vim.fn.fnamemodify(abs_path, ":t")
              local content = table.concat(vim.fn.readfile(abs_path), "\n")
              table.insert(results, string.format("--- %s ---\n%s", basename, content))
            else
              table.insert(errors, rel_path)
            end
          end

          if #errors > 0 then
            table.insert(results, string.format("\n--- NOT FOUND: %s ---", table.concat(errors, ", ")))
          end

          return res:text(table.concat(results, "\n\n")):send()
        end,
      })

      M.register_agent_skills()

      -- Advanced mcphub configuration
      require("mcp-diagnostics").setup({
        mode = "mcphub",

        mcphub = {
          -- Server identification
          server_name = "mcp-diagnostics",
          display_name = "Neovim Diagnostics & LSP",

          -- Auto-approve: Let AI run diagnostic tools without asking
          auto_approve = false, -- Set to true for seamless experience

          -- Feature toggles
          enable_diagnostics = true, -- Diagnostic tools
          enable_lsp = true, -- LSP tools
          enable_prompts = true, -- Investigation guides

          -- Other options
          debug = nvim.lsp.ai.debug, -- Show detailed logs
          lsp_timeout = 1000, -- LSP operation timeout (ms)
          auto_register = true, -- Auto-register with mcphub
          auto_reload_files = true, -- Automatically reload changed files
        },
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

  ---@param skill {name:string, description:string, body:string, frontmatter:table<string,string>}
  ---@return string
  local function build_skill_load_prompt(skill)
    return string.format(
      '\n\n**!!CRITICAL!!:** Load the `%s` skill using `mcp__mcphub__skills__read_skill` before processing with arguments `{ "names": ["%s"] }`, then follow its instructions of the SKILL.\n\n',
      skill.name,
      skill.name
    )
  end

  for _, skill in ipairs(skills) do
    mcphub.add_prompt("skills", {
      name = skill.name,
      description = skill.description,
      handler = function(req, res)
        local file_content = vim.fn.readfile(skill.file_path)
        if file_content and #file_content > 0 then
          skill = M.parse_skill_markdown(table.concat(file_content, "\n"), skill.name)

          return res:user():text(build_skill_load_prompt(skill)):send()
        end

        return res:user():text(build_skill_load_prompt(skill)):send()
      end,
    })
  end

  M._agent_skills_registered = true
end

return M
