-- https://github.com/olimorris/codecompanion.nvim
local M = {}

M.name = "olimorris/codecompanion.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.chat.provider, "codecompanion"), {
    plugin = function()
      ---@type Plugin
      return {
        "olimorris/codecompanion.nvim",
        cmd = { "CodeCompanion", "CodeCompanionCmd", "CodeCompanionActions", "CodeCompanionChat" },
        dependencies = {
          "ravitemer/codecompanion-history.nvim",
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
      return {
        opts = {
          log_level = require("ck.log"):to_nvim_level(),
        },
        adapters = {
          http = {
            anthropic = function()
              return require("codecompanion.adapters").extend("anthropic", {
                env = {
                  api_key = "ANTHROPIC_API_KEY",
                },
              })
            end,
          },
          acp = {
            claude_code = function()
              return require("codecompanion.adapters").extend("claude_code", {
                env = {
                  CLAUDE_CODE_OAUTH_TOKEN = vim.env["CLAUDE_CODE_OAUTH_TOKEN"],
                },
                defaults = {
                  mcpServers = {
                    {
                      name = "mcphub",
                      type = "sse",
                      url = "http://localhost:37373/mcp",
                      args = {},
                      command = "",
                      headers = {},
                      env = {},
                    },
                  },
                },
                commands = {
                  default = { "claude-code-acp" },
                },
              })
            end,
            goose = function()
              return require("codecompanion.adapters").extend("goose", {
                env = {
                  GOOSE_PROVIDER = "cursor-agent",
                  GOOSE_MODEL = "composer-1",
                },
                defaults = {
                  timeout = 60000,
                  mcpServers = {
                    {
                      name = "mcphub",
                      type = "sse",
                      url = "http://localhost:37373/mcp",
                      args = {},
                      command = "",
                      headers = {},
                      env = {},
                    },
                  },
                },
                commands = {
                  default = { "goose", "acp" },
                },
              })
            end,
          },
        },
        rules = {
          claude_code = {
            description = "Rules files for Claude Code users",
            files = {
              "~/.claude/CLAUDE.md",
              "CLAUDE.md",
              "CLAUDE.local.md",
            },
          },
          opts = {
            chat = {
              enabled = true,
            },
          },
        },
        interactions = {
          chat = {
            adapter = nvim.lsp.ai.provider.chat,
            model = nvim.lsp.ai.model.chat,
            opts = {
              ---@param ctx CodeCompanion.SystemPrompt.Context
              ---@return string
              system_prompt = function(ctx)
                return ctx.default_system_prompt
                  .. [[

- ALWAYS read your memory file from the repository before performing any operations. If substantial changes have happened during session, ALWAYS ask to update the memory file accordingly.
- ALWAYS read the file first before using your edit tools to do changes.
- NEVER write comments or explanations unless it is explicitly asked or required or the style of coding has comments to indicate links and other things already, please output these directly to the chat window.
- NEVER fabricate information. If you are unsure, say "I don't know" or consult to a web search or a documentation search.
- NEVER overwrite the explicit changes that is done over your changes unless instructed to do so and ALWAYS analyze them first to take it as a guideline for coding standards.
- You have access to MCP server tools to help you perform coding tasks. Please use them whenever necessary.
- You should use the web search tools instead of guessing answers for up-to-date information which are as follows.
  - built-in search tool
  - `web_search`
  - `mcp__mcphub_nvim__fetch__fetch`
- Use the memory tools provided to you through the MCP server to record milestones about this repository which are as follows.
  - `mcp__mcphub_nvim__memory__create_entities`
  - `mcp__mcphub_nvim__memory__create_relations`
  - `mcp__mcphub_nvim__memory__add_observations`
  - `mcp__mcphub_nvim__memory__delete_entities`
  - `mcp__mcphub_nvim__memory__delete_observations`
  - `mcp__mcphub_nvim__memory__delete_relations`
  - `mcp__mcphub_nvim__memory__read_graph`
  - `mcp__mcphub_nvim__memory__search_nodes`
  - `mcp__mcphub_nvim__memory__open_nodes`
- Please use context7 to fetch anytime you need to access documentation whenever it is possible which are as follows.
  - `mcp__mcphub_nvim__context7__resolve-library-id`
  - `mcp__mcphub_nvim__context7__get-library-docs`
]]
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
            diff_window = {
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
            variables = {
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
                    "cmd_runner",
                    "create_file",
                    "file_search",
                    "get_changed_files",
                    "grep_search",
                    "insert_edit_into_file",
                    "list_code_usages",
                    "read_file",
                    -- "mcp",
                    -- "neovim",
                  },
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
              ["read_file"] = {
                opts = {
                  require_approval_before = false,
                },
              },
              ["list_code_usages"] = {
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
                modes = { n = "<C-c>", i = "<C-c>" },
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
                modes = { n = fn.local_keystroke({ "p" }) },
              },
              buffer_sync_diff = {
                modes = { n = fn.local_keystroke({ "w" }) },
              },
              next_chat = {
                modes = { n = fn.local_keystroke({ "}" }) },
              },
              previous_chat = {
                modes = { n = fn.local_keystroke({ "{" }) },
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
                modes = { n = fn.local_keystroke({ "a", "s" }) },
              },
              super_diff = {
                modes = { n = fn.local_keystroke({ "d" }) },
              },
              _acp_allow_once = {
                modes = { n = fn.local_keystroke({ "c", "a" }) },
              },
              _acp_reject_once = {
                modes = { n = fn.local_keystroke({ "c", "r" }) },
              },
              _acp_allow_always = {
                modes = { n = fn.local_keystroke({ "c", "A" }) },
              },
              _acp_reject_always = {
                modes = { n = fn.local_keystroke({ "c", "R" }) },
              },
            },
          },
          inline = {
            adapter = {
              name = nvim.lsp.ai.provider.chat,
              model = nvim.lsp.ai.model.chat,
            },
            keymaps = {
              accept_change = {
                modes = { n = fn.local_keystroke({ "ca" }) },
              },
              reject_change = {
                modes = { n = fn.local_keystroke({ "cr" }) },
              },
              always_accept = {
                modes = { n = fn.local_keystroke({ "aa" }) },
              },
            },
          },
        },
        display = {
          diff = {
            enabled = true,
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
              make_vars = true, -- Convert MCP resources to #variables for prompts
              -- MCP Prompts
              make_slash_commands = true, -- Add MCP prompts as /slash commands
            },
          },
          history = {
            enabled = true,
            opts = {
              -- Keymap to open history from chat buffer (default: gh)
              keymap = fn.local_keystroke({ "f" }),
              -- Keymap to save the current chat manually (when auto_save is disabled)
              save_chat_keymap = fn.local_keystroke({ "W" }),
              -- Save all chats by default (disable to save only manually using 'sc')
              auto_save = true,
              -- Number of days after which chats are automatically deleted (0 to disable)
              expiration_days = 0,
              -- Picker interface (auto resolved to a valid picker)
              picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
              ---Optional filter function to control which chats are shown when browsing
              chat_filter = nil, -- function(chat_data) return boolean end
              -- Customize picker keymaps (optional)
              picker_keymaps = {
                rename = { n = "r", i = "<C-r>" },
                delete = { n = "d", i = "<C-d>" },
                duplicate = { n = "<C-y>", i = "<C-y>" },
              },
              ---Automatically generate titles for new chats
              auto_generate_title = true,
              title_generation_opts = {
                ---Adapter for generating titles (defaults to current chat adapter)
                adapter = "copilot", -- "copilot"
                ---Model for generating titles (defaults to current chat model)
                model = "gpt-5", -- "gpt-4o"
                ---Number of user prompts after which to refresh the title (0 to disable)
                refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
                ---Maximum number of times to refresh the title (default: 3)
                max_refreshes = 3,
                format_title = function(original_title)
                  -- this can be a custom function that applies some custom
                  -- formatting to the title.
                  return original_title
                end,
              },
              ---On exiting and entering neovim, loads the last chat on opening chat
              continue_last_chat = false,
              ---When chat is cleared with `gx` delete the chat from history
              delete_on_clearing_chat = false,
              ---Directory path to save the chats
              dir_to_save = join_paths(get_cache_dir(), "codecompanion-history"),
              ---Enable detailed logging for history extension
              enable_logging = false,

              -- Summary system
              summary = {
                -- Keymap to generate summary for current chat (default: "gcs")
                create_summary_keymap = fn.local_keystroke({ "s", "c" }),
                -- Keymap to browse summaries (default: "gbs")
                browse_summaries_keymap = fn.local_keystroke({ "s", "f" }),

                generation_opts = {
                  adapter = "copilot", -- defaults to current chat adapter
                  model = "gpt-5", -- defaults to current chat model
                  context_size = 90000, -- max tokens that the model supports
                  include_references = true, -- include slash command content
                  include_tool_outputs = true, -- include tool execution results
                  system_prompt = nil, -- custom system prompt (string or function)
                  format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
                },
              },
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
            require("codecompanion").chat()
          end,
          desc = "new chat [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "Q" }),
          function()
            require("codecompanion").close_last_chat()
          end,
          desc = "close last chat [codecompanion]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "e" }),
          function()
            require("codecompanion").add({})
          end,
          desc = "add selected code [codecompanion]",
          mode = { "n", "v" },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").set_view_buffer({ "codecompanion" }),
      }
    end,
  })
end

return M
