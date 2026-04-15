-- https://github.com/olimorris/codecompanion.nvim
local M = {}

local log = require("ck.log")

M.name = "olimorris/codecompanion.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.chat.provider, "codecompanion"), {
    plugin = function()
      ---@type Plugin
      return {
        "olimorris/codecompanion.nvim",
        -- "cenk1cenk2/codecompanion.nvim",
        -- branch = "next",
        -- dir = "~/development/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionCmd", "CodeCompanionActions", "CodeCompanionChat" },
        keys = { "<Space>c" },
        dependencies = {
          -- "ravitemer/mcphub.nvim",
          -- TODO: POINT TO ORIGINAL WHEN FORK MERGES OR IF MERGES?
          "cenk1cenk2/mcphub.nvim",
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "codecompanion",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            title = "CodeCompanion",
            ft = "codecompanion",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.5
                end

                return 180
              end,
            },
          },
        })

        return c
      end)
    end,
    setup = function(_, fn)
      local instance = require("mcphub").get_hub_instance()

      local function get_mcphub_mcp_servers()
        log:info("Connecting to MCPHub...")

        local ok = vim.wait(15000, function()
          instance = require("mcphub").get_hub_instance()
          return instance ~= nil and instance:is_ready()
        end, 250)

        if not ok or not instance then
          log:warn("MCPHub instance not ready in time.")
        end

        local proxy = require("mcphub.extensions.proxy").get()
        log:info("Connected to MCPHub instance: :%d through %s", instance.port, proxy.args)

        return vim.tbl_extend("force", {
          name = "mcphub",
        }, proxy)
      end

      return {
        opts = {
          log_level = require("ck.log"):to_nvim_level(),
          -- log_level = "DEBUG",
        },
        mcp = {
          servers = {
            ["mcphub"] = {
              cmd = vim.list_extend({ "bun" }, get_mcphub_mcp_servers().args),
              tool_defaults = {
                require_approval_before = false,
              },
            },
          },
          opts = {
            default_servers = { "mcphub" },
            timeout = 240000,
          },
        },
        adapters = {
          http = {
            tavily = {
              env = {
                api_key = "NVIM_TAVILY_API_KEY",
              },
            },
          },
          acp = {
            ---@type fun (): CodeCompanion.ACPAdapter
            claude_code = function()
              if vim.env["NVIM_CLAUDE_ACP"] == nil then
                vim.env["NVIM_CLAUDE_ACP"] = vim.env["NVIM_CLAUDE_ACP_WORK"]
              end

              log:debug("Setting up the AI Overlord...")

              return require("codecompanion.adapters.acp").extend(
                "claude_code",
                ---@type CodeCompanion.ACPAdapter
                {
                  env = {
                    PATH = vim.env["PATH"],
                    HOME = vim.env["HOME"],
                    USER = vim.env["USER"],
                    ANTHROPIC_API_KEY = nil,
                    CLAUDE_CODE_OAUTH_TOKEN = vim.env["NVIM_CLAUDE_ACP"],
                  },
                  opts = {
                    verbose_output = true,
                  },
                  defaults = {
                    mcpServers = "inherit_from_config",
                    mode = "plan",
                  },
                  commands = {
                    default = { "bunx", "-y", "@agentclientprotocol/claude-agent-acp@latest" },
                    yolo = { "bunx", "-y", "@agentclientprotocol/claude-agent-acp@latest", "--yolo" },
                  },
                }
              )
            end,
            ---@type fun (): CodeCompanion.ACPAdapter
            kilic = function()
              log:debug("Setting up the AI Overlord...")

              return require("codecompanion.adapters.acp").extend(
                "opencode",
                ---@type CodeCompanion.ACPAdapter
                {
                  name = "kilic",
                  formatted_name = "kilic",
                  env = {
                    PATH = vim.env["PATH"],
                    HOME = vim.env["HOME"],
                    USER = vim.env["USER"],
                    OPENCODE_CONFIG = vim.fn.expand("~/.config/nvim/utils/agents/opencode/kilic.json"),
                    AI_KILIC_DEV_API_KEY = vim.env["AI_KILIC_DEV_API_KEY"],
                  },
                  opts = {
                    verbose_output = true,
                  },
                  defaults = {
                    mcpServers = "inherit_from_config",
                    mode = "plan",
                  },
                  commands = {
                    default = { "opencode", "acp" },
                  },
                }
              )
            end,
            ---@type fun (): CodeCompanion.ACPAdapter
            opencode = function()
              log:debug("Setting up the AI Overlord...")

              return require("codecompanion.adapters.acp").extend(
                "opencode",
                ---@type CodeCompanion.ACPAdapter
                {
                  env = {
                    PATH = vim.env["PATH"],
                    HOME = vim.env["HOME"],
                    USER = vim.env["USER"],
                    OPENCODE_CONFIG = vim.fn.expand("~/.config/nvim/utils/agents/opencode/zen.json"),
                    OPENCODE_API_KEY = vim.env["NVIM_OPENCODE_ACP_WORK"],
                  },
                  opts = {
                    verbose_output = true,
                  },
                  defaults = {
                    mcpServers = "inherit_from_config",
                    mode = "plan",
                  },
                  commands = {
                    default = { "opencode", "acp" },
                  },
                }
              )
            end,
            ---@type fun (): CodeCompanion.ACPAdapter
            codex = function()
              if vim.env["NVIM_CODEX_ACP"] == nil then
                vim.env["NVIM_CODEX_ACP"] = vim.env["NVIM_CODEX_ACP_KILIC"]
              end

              log:debug("Setting up the AI Overlord...")

              return require("codecompanion.adapters.acp").extend(
                "codex",
                ---@type CodeCompanion.ACPAdapter
                {
                  env = {
                    PATH = vim.env["PATH"],
                    HOME = vim.env["HOME"],
                    USER = vim.env["USER"],
                    CODEX_API_KEY = vim.env["NVIM_CODEX_ACP"],
                  },
                  opts = {
                    verbose_output = true,
                  },
                  defaults = {
                    -- TODO: something was not working here
                    -- auth_method="codex-api-key",
                    auth_method = "chatgpt",
                    mcpServers = "inherit_from_config",
                    mode = "plan",
                  },
                  commands = {
                    default = { "bunx", "-y", "@agentclientprotocol/codex-acp@latest" },
                  },
                }
              )
            end,
          },
        },
        rules = {
          agents = {
            description = "Rules files for agent workflows",
            files = {
              { path = "~/.config/nvim/utils/agents/AGENTS.md" },
              { path = "AGENTS.md" },
              { path = "AGENTS.local.md" },
              { path = "~/.claude/CLAUDE.md", parser = "claude" },
              { path = "CLAUDE.md", parser = "claude" },
              { path = "CLAUDE.local.md", parser = "claude" },
              ".clinerules",
              ".cursorrules",
              ".goosehints",
              ".rules",
              ".windsurfrules",
              ".github/copilot-instructions.md",
              "AGENT.md",
              "OPENCODE.md",
            },
          },
          opts = {
            chat = {
              enabled = true,
              autoload = "agents",
            },
          },
        },
        interactions = {
          background = {
            adapter = {
              name = "copilot",
              model = "gpt-5-mini",
            },
            chat = {
              callbacks = {
                ["on_ready"] = {
                  actions = {
                    "interactions.background.builtin.chat_make_title",
                  },
                  enabled = true,
                },
              },
              opts = {
                enabled = true,
              },
            },
          },
          chat = {
            adapter = nvim.lsp.ai.provider.chat,
            model = nvim.lsp.ai.model.chat,
            opts = {
              ---@param ctx CodeCompanion.SystemPrompt.Context
              ---@return string
              system_prompt = function(ctx)
                return ctx.default_system_prompt
              end,
            },
            window = {
              border = nvim.ui.border,
              numberwidth = 0,
              sticky = true,
              opts = {
                numberwidth = 0,
              },
            },
            editor_context = {
              ["buffer"] = {
                opts = {
                  --- https://codecompanion.olimorris.dev/usage/chat-buffer/variables#with-parameters
                  default_params = "diff", -- all|diff
                },
              },
            },
            tools = {
              groups = {
                ["default"] = {
                  -- prompt = [[I'm giving you access to the ${tools} to help you perform coding tasks. Please use neovim mcp adapter first for any kind of file based operations. Please use fetch for web searches.]],
                  tools = {
                    "run_command",
                    "create_file",
                    "file_search",
                    "get_changed_files",
                    "grep_search",
                    "insert_edit_into_file",
                    "read_file",
                    "web_search",
                    "fetch_webpage",
                    -- "mcp",
                    -- "neovim",
                  },
                },
              },
              ["memory"] = {
                opts = {
                  whitelist = {
                    { path = "~/notes/Repositories/", as = "obsidian" },
                  },
                },
              },
              ["read_file"] = {
                opts = {
                  require_approval_before = function(tool)
                    local path = tool.args and tool.args.filepath or ""
                    path = vim.fs.normalize(path)
                    for _, dir in ipairs(M.auto_approve_read_dirs) do
                      if path:find(dir, 1, true) == 1 then
                        return false
                      end
                    end
                    return true
                  end,
                },
              },
              ["create_file"] = {
                opts = {
                  require_approval_before = function(tool)
                    local path = tool.args and tool.args.filepath or ""
                    path = vim.fs.normalize(path)
                    for _, dir in ipairs(M.auto_approve_write_dirs) do
                      if path:find(dir, 1, true) == 1 then
                        return false
                      end
                    end
                    return true
                  end,
                },
              },
              ["insert_edit_into_file"] = {
                opts = {
                  require_approval_before = function(tool)
                    local path = tool.args and tool.args.filepath or ""
                    path = vim.fs.normalize(path)
                    for _, dir in ipairs(M.auto_approve_write_dirs) do
                      if path:find(dir, 1, true) == 1 then
                        return false
                      end
                    end
                    return true
                  end,
                },
              },
              ["web_search"] = {
                opts = {
                  require_approval_before = false,
                },
              },
              ["fetch_webpage"] = {
                opts = {
                  require_approval_before = false,
                },
              },
              ["file_search"] = {
                opts = {
                  require_approval_before = false,
                },
              },
              ["get_changed_files"] = {
                opts = {
                  require_approval_before = false,
                },
              },
              ["grep_search"] = {
                opts = {
                  require_approval_before = false,
                },
              },
              opts = {
                auto_submit_errors = true,
                auto_submit_success = true,
                default_tools = { "default" },
              },
            },
            roles = {
              ---The header name for the LLM's messages
              ---@type string|fun(adapter: CodeCompanion.Adapter): string
              llm = function(adapter)
                local model
                local chat = require("codecompanion").buf_get_chat(0)

                if chat then
                  if chat.acp_connection then
                    local models = chat.acp_connection:get_models()
                    if models and models.currentModelId then
                      model = models.currentModelId
                    end
                  else
                    model = adapter.model and (adapter.model.formatted_name or adapter.model.name)
                  end
                end

                if model then
                  return ("AI Overlord - %s (%s)"):format(adapter.formatted_name, model)
                end

                return ("AI Overlord - %s"):format(adapter.formatted_name)
              end,

              ---The header name for your messages
              ---@type string
              user = "Retarded Peasant",
            },
            keymaps = {
              options = {
                modes = { n = "?" },
              },
              completion = {
                modes = { i = "<C-_>" },
              },
              send = {
                modes = { n = { "<CR>", "<C-s>" }, i = "<C-s>" },
              },
              close = {
                modes = { n = "<C-q>", i = "<C-q>" },
              },
              regenerate = {
                modes = { n = fn.local_keystroke({ "r" }) },
              },
              stop = {
                modes = { n = fn.local_keystroke({ "q" }) },
              },
              clear = {
                modes = { n = fn.local_keystroke({ "Q" }) },
              },
              codeblock = {
                modes = { n = fn.local_keystroke({ "c" }) },
              },
              yank_code = {
                modes = { n = fn.local_keystroke({ "y" }) },
              },
              buffer_sync_all = {
                modes = { n = fn.local_keystroke({ "s", "p" }) },
              },
              buffer_sync_diff = {
                modes = { n = fn.local_keystroke({ "s", "w" }) },
              },
              next_chat = {
                modes = { n = fn.local_keystroke({ "n" }) },
              },
              previous_chat = {
                modes = { n = fn.local_keystroke({ "p" }) },
              },
              next_header = {
                modes = { n = fn.local_keystroke({ "]" }) },
              },
              previous_header = {
                modes = { n = fn.local_keystroke({ "[" }) },
              },
              change_adapter = {
                modes = { n = fn.local_keystroke({ "a", "a" }) },
              },
              fold_code = {
                modes = { n = fn.local_keystroke({ "a", "z" }) },
              },
              debug = {
                modes = { n = fn.local_keystroke({ "?" }) },
              },
              system_prompt = {
                modes = { n = fn.local_keystroke({ "a", "p" }) },
              },
              rules = {
                modes = { n = fn.local_keystroke({ "D" }) },
              },
              yolo_mode = {
                modes = { n = fn.local_keystroke({ "a", "t" }) },
              },
              goto_file_under_cursor = {
                modes = { n = "gf" },
              },
              copilot_stats = {
                modes = { n = fn.local_keystroke({ "a", ".", "s" }) },
              },
              clear_approvals = {
                modes = { n = fn.local_keystroke({ "a", "X" }) },
              },
              delete_chat = {
                modes = { n = fn.local_keystroke({ "X" }) },
                callback = function(chat)
                  local open_chats = M.get_open_chats()

                  if #open_chats <= 1 then
                    chat:close()

                    return
                  end

                  local window_opts = chat.ui and chat.ui.window_opts or { default = true }
                  local next_chat

                  for index, entry in ipairs(open_chats) do
                    if entry.bufnr == chat.bufnr then
                      next_chat = open_chats[(index % #open_chats) + 1].chat

                      break
                    end
                  end

                  if not next_chat then
                    next_chat = open_chats[1].chat
                  end

                  chat:close()

                  if next_chat and next_chat.bufnr ~= chat.bufnr then
                    next_chat.ui:open({ window_opts = window_opts })
                  end
                end,
                description = "Delete current chat from session",
              },
              -- browse_project_chats = {
              --   modes = { n = fn.local_keystroke({ "f" }) },
              --   callback = function()
              --     require("codecompanion").extensions.history.browse_chats(function(chat_data)
              --       return chat_data.project_root == require("codecompanion._extensions.history.utils").find_project_root()
              --     end)
              --   end,
              --   description = "Browse chats for current project",
              -- },
              -- browse_all_chats = {
              --   modes = { n = fn.local_keystroke({ "F" }) },
              --   callback = function()
              --     require("codecompanion").extensions.history.browse_chats()
              --   end,
              --   description = "Browse all chats",
              -- },
              browse_open_chats = {
                modes = { n = fn.local_keystroke({ "f" }) },
                callback = M.browse_open_chats,
                description = "Browse open chats",
              },
            },
          },
          inline = {
            adapter = {
              name = nvim.lsp.ai.provider.chat,
              model = nvim.lsp.ai.model.chat,
            },
          },
          shared = {
            keymaps = {
              view_diff = {
                modes = { n = "gd" },
              },
              always_accept = {
                modes = { n = "ga" },
              },
              accept_change = {
                modes = { n = ",." },
              },
              reject_change = {
                modes = { n = ",," },
              },
              cancel = {
                modes = { n = "<C-c>" },
              },
            },
          },
        },
        prompt_library = {
          markdown = {
            dirs = (function()
              local base = vim.fn.expand("~/.config/nvim/utils/agents/skills")
              local dirs = {}
              for _, entry in ipairs(vim.fn.readdir(base)) do
                local path = base .. "/" .. entry
                if vim.fn.isdirectory(path) == 1 and entry ~= "references" then
                  table.insert(dirs, path)
                end
              end
              return dirs
            end)(),
          },
        },
        display = {
          action_palette = {
            opts = {
              show_prompt_library_builtins = false,
            },
          },
          diff = {
            enabled = true,
            window = {
              ---@return number|fun(): number
              width = function()
                return math.min(180, vim.o.columns - 10)
              end,
              ---@return number|fun(): number
              height = function()
                return vim.o.lines - 4
              end,
              opts = {
                number = true,
              },
            },
          },
          chat = {
            show_header_separator = true,
            show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
            fold_context = true, -- Fold context in the chat buffer?
            show_settings = false, -- Show LLM settings at the top of the chat buffer?
            show_tools_processing = true, -- Show the loading message when tools are being executed?
            show_token_count = true, -- Show the token count for each response?
            start_in_insert_mode = true, -- Open the chat buffer in insert mode?
          },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              -- MCP Tools
              make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
              show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
              add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
              show_result_in_chat = true, -- Show tool results directly in chat buffer
              -- format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
              -- MCP Resources
              -- TODO: SET ME TRUE AFTER THE PLUGIN UPDATE
              make_vars = true,
              -- MCP Prompts
              make_slash_commands = true, -- Add MCP prompts as /slash commands
            },
          },
        },
      }
    end,
    on_setup = function(c)
      require("codecompanion").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("codecompanion").toggle()
          end,
          desc = "toggle chat [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "C" }),
          function()
            local adapters = {
              { name = "claude_code", type = "acp" },
              -- { name = "codex", type = "acp" },
              { name = "kilic", type = "acp" },
              { name = "opencode", type = "acp" },
            }

            vim.ui.select(adapters, {
              prompt = "Select an adapter for this chat",
              format_item = function(item)
                return ("%s [%s]"):format(item.name, item.type)
              end,
            }, function(selected)
              if not selected then
                return
              end

              local adapter = selected.name

              require("codecompanion").chat({
                params = {
                  adapter = adapter,
                },
                callbacks = {
                  on_created = function(chat)
                    if selected.type == "http" then
                      require("codecompanion.interactions.chat.keymaps.change_adapter").select_model(chat)

                      return
                    end

                    -- ACP connection is created async — use change_adapter callback
                    -- to wait until the connection is ready before selecting a model.
                    chat:change_adapter(adapter, function()
                      if not chat.acp_connection then
                        log:warn("Selected adapter '%s' does not have an ACP connection. Cannot select model.", adapter)

                        return
                      end

                      local models = chat.acp_connection:get_models()

                      if not models or not models.availableModels or #models.availableModels < 2 then
                        return
                      end

                      vim.ui.select(models.availableModels, {
                        prompt = "Select a model for this chat",
                        format_item = function(item)
                          return ("%s (%s)"):format(item.name or item.modelId, item.description) .. (item.modelId == models.currentModelId and " [*]" or "")
                        end,
                      }, function(model)
                        if not model then
                          return
                        end

                        chat:change_model({ model = model.modelId })
                      end)
                    end)
                  end,
                },
              })
            end)
          end,
          desc = "new chat [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            vim.cmd("CodeCompanionActions")
          end,
          desc = "actions [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "<Space>" }),
          function()
            local codecompanion = require("codecompanion")
            local last = codecompanion.last_chat()

            if not last then
              return
            end

            local chat_bufnr = last.bufnr
            if not chat_bufnr or not vim.api.nvim_buf_is_valid(chat_bufnr) then
              return
            end

            local current_buf = vim.api.nvim_get_current_buf()

            if current_buf == chat_bufnr then
              vim.cmd("wincmd p")
            else
              local chat_win
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == chat_bufnr then
                  chat_win = win
                  break
                end
              end

              if chat_win then
                vim.api.nvim_set_current_win(chat_win)
              else
                last.ui:open()
              end
            end
          end,
          desc = "focus sidebar [codecompanion]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "p" }),
          M.browse_open_chats,
          desc = "open chats [codecompanion]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "X" }),
          function()
            require("codecompanion").close_last_chat()
          end,
          desc = "close last chat [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "Q" }),
          function()
            vim.cmd([[Lazy reload codecompanion.nvim]])
          end,
          desc = "reload [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "a" }),
          function()
            require("codecompanion").add({})
          end,
          desc = "add selected code [codecompanion]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "A" }),
          function()
            local bufnr = vim.api.nvim_get_current_buf()
            local codecompanion = require("codecompanion")
            local chat = codecompanion.last_chat()

            if not chat then
              chat = codecompanion.chat({
                context = require("codecompanion.utils.context").get(bufnr),
              })
            end

            if not chat then
              return
            end

            local config = require("codecompanion.config")
            local Variable = require("codecompanion.interactions.shared.editor_context.buffer")
            local var = Variable.new({
              Chat = chat,
              config = config.interactions.shared.editor_context["buffer"] or {},
              params = (config.interactions.shared.editor_context["buffer"] or {}).opts and config.interactions.shared.editor_context["buffer"].opts.default_params,
            })

            var:output({ bufnr = bufnr })

            log:info("Added buffer to chat context: %s", require("ck.utils.fs").get_project_buffer_filepath(bufnr))
          end,
          desc = "add current buffer to context [codecompanion]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "P" }),
          function()
            vim.ui.select({
              {
                name = "Personal",
                env = {
                  NVIM_CLAUDE_ACP = vim.env["NVIM_CLAUDE_ACP_KILIC"],
                  NVIM_CODEX_ACP = vim.env["NVIM_CODEX_ACP_KILIC"],
                },
              },
              {
                name = "Work",
                env = {
                  NVIM_CLAUDE_ACP = vim.env["NVIM_CLAUDE_ACP_WORK"],
                },
              },
            }, {
              prompt = "Select Claude Code ACP Profile",
              format_item = function(item)
                return item.name
              end,
            }, function(selected)
              if not selected then
                return
              end

              log:info("Switching to Claude Code profile: %s", selected.name)

              vim.env["NVIM_CLAUDE_ACP"] = selected.env["NVIM_CLAUDE_ACP"]
              vim.env["NVIM_CODEX_ACP"] = selected.env["NVIM_CODEX_ACP"]
            end)
          end,
          desc = "select profile for claude [codecompanion]",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").set_view_buffer({ "codecompanion" }),
        {
          event = "User",
          group = "_codecompanion_markview",
          pattern = "CodeCompanionRequestStarted",
          once = true,
          callback = function(ev)
            local bufnr = ev.data and ev.data.bufnr
            pcall(require("markview.actions").render, bufnr)
          end,
        },
        {
          event = "User",
          group = "_codecompanion_tmux_alert",
          pattern = {
            "CodeCompanionToolApprovalRequested",
            "MCPHubApprovalWindowOpened",
            "CodeCompanionRequestFinished",
            "CodeCompanionRequestError",
          },
          callback = function()
            local tty = vim.uv.new_tty(2, false)
            if tty then
              tty:write("\007")
              tty:close()
            end
          end,
        },
        {
          event = "User",
          group = "_codecompanion_background_title_refresh",
          pattern = "CodeCompanionChatDone",
          callback = function(ev)
            local bufnr = ev.data and ev.data.bufnr
            if not bufnr then
              return
            end

            local chat = require("codecompanion").buf_get_chat(bufnr)
            if not chat then
              return
            end

            if not chat._bg_title_state then
              chat._bg_title_state = { count = 0, refreshes = 0 }
            end

            local state = chat._bg_title_state
            state.count = state.count + 1

            local interval = state.count <= 15 and 3 or 15
            if state.count % interval ~= 0 then
              return
            end

            local Background = require("codecompanion.interactions.background")
            local make_title = require("codecompanion.interactions.background.builtin.chat_make_title")

            local background = Background.new()
            if not background then
              return
            end

            background:ask({
              {
                role = "system",
                content = "You are an expert in crafting pithy titles for chatbot conversations. You are presented with a chat request, and you reply with a brief title that captures the main topic of that request. Keep your answers short and impersonal.\nThe title should not be wrapped in quotes or contain any sort of formatting such as Markdown or HTML syntax. It should be about 8 words or fewer.\nHere are some examples of good titles:\n- Git rebase question\n- Installing Python packages\n- Location of LinkedList implementation in codebase\n- Adding tests to Neovim plugin\n- React useState hook usage",
              },
              {
                role = "user",
                content = string.format("Please write a brief title for the following request:\n\n%s", make_title.format_messages(chat.messages)),
              },
            }, {
              method = "async",
              silent = true,
              on_done = function(result)
                local title = make_title.on_done(result)
                if title then
                  chat:set_title(title)
                  log:debug("[Background] Chat title refreshed: %s", title)
                end
              end,
            })
          end,
        },
      }
    end,
  })
end

-- Directories where read operations are auto-approved (no user confirmation needed).
M.auto_approve_read_dirs = {
  vim.fs.normalize("~/.config/nvim/utils/agents/skills"),
  vim.fs.normalize("~/.claude/plans"),
  vim.fs.normalize("~/.claude/projects"),
}

-- Directories where write operations are auto-approved (no user confirmation needed).
M.auto_approve_write_dirs = {
  vim.fs.normalize("~/.claude/plans"),
  vim.fs.normalize("~/.claude/projects"),
}

function M.get_open_chats()
  local codecompanion = require("codecompanion")
  local chat_metadata = _G.codecompanion_chat_metadata or {}
  local open_chats = {}

  for _, item in ipairs(codecompanion.buf_get_chat() or {}) do
    local chat = item.chat or item
    local bufnr = chat and chat.bufnr

    if type(bufnr) == "number" and vim.api.nvim_buf_is_valid(bufnr) then
      local metadata = chat_metadata[bufnr] or {}
      local title = (chat.opts and chat.opts.title) or chat.title or item.description or item.title or "Untitled Chat"
      local adapter = (metadata.adapter and metadata.adapter.name) or (chat.adapter and (chat.adapter.formatted_name or chat.adapter.name)) or "Unknown"

      table.insert(open_chats, {
        bufnr = bufnr,
        chat = chat,
        title = title,
        adapter = adapter,
        display = string.format("[%s] %s", adapter, title),
      })
    end
  end

  table.sort(open_chats, function(a, b)
    return a.bufnr < b.bufnr
  end)

  return open_chats
end

function M.browse_open_chats()
  local open_chats = M.get_open_chats()

  if #open_chats == 0 then
    vim.notify("No open chats", vim.log.levels.INFO)

    return
  end

  local codecompanion = require("codecompanion")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local previewers = require("telescope.previewers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({}, {
      prompt_title = "Open Chats",
      finder = finders.new_table({
        results = open_chats,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.display,
            ordinal = string.format("%s %s", entry.adapter, entry.title),
            bufnr = entry.bufnr,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Chat Preview",
        define_preview = function(preview_state, entry)
          local selected = entry and entry.value
          local lines

          if not selected then
            lines = { "No chat selected" }
          elseif type(selected.bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(selected.bufnr) then
            lines = { "Chat buffer is no longer valid" }
          else
            if not vim.api.nvim_buf_is_loaded(selected.bufnr) then
              pcall(vim.fn.bufload, selected.bufnr)
            end

            local ok, chat_lines = pcall(vim.api.nvim_buf_get_lines, selected.bufnr, 0, -1, false)

            lines = {}

            if ok and chat_lines and #chat_lines > 0 then
              vim.list_extend(lines, chat_lines)
            else
              table.insert(lines, "[Empty chat buffer]")
            end
          end

          vim.bo[preview_state.state.bufnr].filetype = "markdown"
          vim.api.nvim_buf_set_lines(preview_state.state.bufnr, 0, -1, false, lines)

          vim.schedule(function()
            if vim.api.nvim_win_is_valid(preview_state.state.winid) then
              vim.api.nvim_win_set_cursor(preview_state.state.winid, { #lines, 0 })
            end
          end)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if not selection or not selection.value or not selection.value.chat then
            return
          end

          local active_chat = codecompanion.last_chat()
          local window_opts = active_chat and active_chat.ui and active_chat.ui.window_opts

          codecompanion.close_last_chat()

          if window_opts then
            selection.value.chat.ui:open({ window_opts = window_opts })

            return
          end

          selection.value.chat.ui:open()
        end)

        local function delete_selected()
          local selection = action_state.get_selected_entry()

          if not selection or not selection.value or not selection.value.chat then
            return
          end

          local selected = selection.value.chat
          local is_active = selected.ui and selected.ui:is_active()
          local window_opts = selected.ui and selected.ui.window_opts or { default = true }
          local next_chat

          for _, entry in ipairs(M.get_open_chats()) do
            if entry.bufnr ~= selected.bufnr then
              next_chat = entry.chat

              break
            end
          end

          selected:close()
          actions.close(prompt_bufnr)

          if is_active and next_chat then
            next_chat.ui:open({ window_opts = window_opts })
          end

          vim.notify("Chat deleted", vim.log.levels.INFO)
        end

        map("i", "<C-d>", delete_selected)
        map("n", "<C-d>", delete_selected)

        return true
      end,
    })
    :find()
end

return M
