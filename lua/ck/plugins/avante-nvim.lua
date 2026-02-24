-- https://github.com/yetone/avante.nvim
local M = {}

local log = require("ck.log")

M.name = "yetone/avante.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.chat.provider, "avante"), {
    plugin = function()
      ---@type Plugin
      return {
        "yetone/avante.nvim",
        build = "make",
        dependencies = {
          { "Kaiser-Yang/blink-cmp-avante" },
          -- TODO: POINT TO ORIGINAL WHEN FORK MERGES OR IF MERGES?
          "cenk1cenk2/mcphub.nvim",
        },
      }
    end,
    configure = function(_, fn)
      vim.env["GOOGLE_SEARCH_ENGINE_ID"] = vim.env["NVIM_GOOGLE_SEARCH_ID"]
      vim.env["GOOGLE_SEARCH_API_KEY"] = vim.env["NVIM_GOOGLE_SEARCH_KEY"]

      fn.add_disabled_filetypes({
        "AvanteSelectedFiles",
        "AvanteInput",
        "AvanteConfirm",
        "AvanteTodos",
        "AvanteClear",
        "AvanteStop",
        "Avante",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            title = "Avante",
            ft = { "Avante", "AvanteSelectedFiles", "AvanteInput", "AvanteTodos" },
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.3
                end

                return 120
              end,
            },
          },
        })

        return c
      end)

      require("ck.setup").setup_callback(require("ck.plugins.blink-cmp").name, function(c)
        c.sources.providers.avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {},
        }

        local cb = c.sources.default

        c.sources.default = function(ctx)
          return vim.list_extend({ "avante" }, cb(ctx))
        end

        return c
      end)
    end,
    setup = function(_, fn)
      local categories = fn.get_wk_categories()

      local function get_acp_provider()
        local provider = nvim.lsp.ai.provider.chat

        if provider == "claude_code" then
          return "claude-code"
        end

        return provider
      end

      local function get_mcp_servers()
        log:info("Connecting to MCPHub...")

        local instance
        local ok = vim.wait(15000, function()
          instance = require("mcphub").get_hub_instance()
          return instance ~= nil and instance:is_ready()
        end, 250)

        if not ok or not instance then
          log:warn("MCPHub instance not ready in time.")
          return {}
        end

        local proxy = require("mcphub.extensions.proxy").get()
        log:info("Connected to MCPHub instance: :%d through %s", instance.port, proxy.args)

        return { proxy }
      end

      ---@type avante.Config
      return {
        debug = nvim.lsp.ai.debug,
        mode = "agentic",
        provider = get_acp_provider(),
        providers = {
          copilot = {
            model = nvim.lsp.ai.model.chat,
          },
        },
        acp_providers = {
          ["claude-code"] = {
            command = "bunx",
            args = { "-y", "@zed-industries/claude-code-acp@latest" },
            env = (function()
              if vim.env["NVIM_CLAUDE_ACP"] == nil then
                vim.env["NVIM_CLAUDE_ACP"] = vim.env["NVIM_CLAUDE_ACP_WORK"]
              end

              return {
                PATH = vim.env["PATH"],
                HOME = vim.env["HOME"],
                USER = vim.env["USER"],
                ANTHROPIC_API_KEY = nil,
                CLAUDE_CODE_OAUTH_TOKEN = vim.env["NVIM_CLAUDE_ACP"],
                -- ACP_PERMISSION_MODE = "bypassPermissions",
              }
            end)(),
            mcp_servers = get_mcp_servers(),
          },
          ["codex"] = {
            command = "bunx",
            args = { "-y", "@zed-industries/codex-acp@latest" },
            env = (function()
              if vim.env["NVIM_CODEX_ACP"] == nil then
                vim.env["NVIM_CODEX_ACP"] = vim.env["NVIM_CODEX_ACP_KILIC"]
              end

              return {
                PATH = vim.env["PATH"],
                HOME = vim.env["HOME"],
                USER = vim.env["USER"],
                CODEX_API_KEY = vim.env["NVIM_CODEX_ACP"],
              }
            end)(),
            mcp_servers = get_mcp_servers(),
          },
        },
        custom_tools = function()
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end,
        web_search_engine = {
          provider = "google",
        },
        rag_service = {
          enabled = nvim.lsp.ai.chat.rag,
          host_mount = os.getenv("HOME"),
          --- NOTE: api key is causing a problem so we are using the open ai client
          llm = {
            provider = "openai",
            endpoint = "https://api.ai.kilic.dev/v1",
            api_key = "AI_KILIC_DEV_API_KEY",
            --- NOTE: this should be an openai model matching cause of pydantic
            model = "o1",
          },
          embed = {
            provider = "openai",
            endpoint = "https://api.ai.kilic.dev/v1",
            api_key = "AI_KILIC_DEV_API_KEY",
            --- NOTE: this should be an openai model matching cause of pydantic
            model = "text-embedding-3-small",
          },
          docker_extra_args = table.concat({
            "-e",
            "OLLAMA_API_KEY=" .. (os.getenv("AI_KILIC_DEV_API_KEY") or ""),
            "-e",
            "OPENAI_API_KEY=" .. (os.getenv("AI_KILIC_DEV_API_KEY") or ""),
          }, " "),
        },
        windows = {
          wrap = true, -- similar to vim.o.wrap
          width = 50, -- default % based on available width
          sidebar_header = {
            rounded = false,
          },
          input = {
            prefix = nvim.ui.icons.misc.Robot .. " ",
            height = 20, -- Height of the input window in vertical layout
          },
        },
        behaviour = {
          auto_set_highlight_group = true,
          auto_set_keymaps = false,
          enable_token_counting = true,
          auto_approve_tool_permissions = false,
          acp_follow_agent_locations = true,
          confirmation_ui_style = "popup",
          -- confirmation_ui_style = "inline_buttons",
          auto_add_current_file = false,
        },
        diff = {
          autojump = true,
        },
        selection = {
          enabled = true,
        },
        file_selector = {
          provider = "telescope",
        },
        selector = {
          provider = "telescope",
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = fn.local_keystroke({ "c", "o" }),
            theirs = fn.local_keystroke({ "c", "t" }),
            all_theirs = fn.local_keystroke({ "c", "a" }),
            both = fn.local_keystroke({ "c", "b" }),
            cursor = fn.local_keystroke({ "c", "c" }),
            next = "]c",
            prev = "[c",
          },
          suggestion = {
            accept = "<M-l>",
            next = "<M-k>",
            prev = "<M-j>",
            dismiss = "<C-h>",
          },
          jump = {
            next = fn.local_keystroke({ "]" }),
            prev = fn.local_keystroke({ "[" }),
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          cancel = {
            normal = { "<C-c>", "q" },
            insert = { "<C-c>" },
          },
          sidebar = {
            expand_tool_use = "zo",
            next_prompt = "]p",
            prev_prompt = "[p",
            apply_all = fn.local_keystroke({ "p" }),
            apply_cursor = fn.local_keystroke({ "w" }),
            switch_windows = "<C-n>",
            reverse_switch_windows = "<C-p>",
            toggle_code_window = fn.local_keystroke({ "x" }),
            remove_file = fn.local_keystroke({ "d" }),
            add_file = fn.local_keystroke({ "f" }),
            close = { "<C-c>" },
            close_from_input = { normal = "<C-c>", insert = "<C-c>" },
            retry_user_request = fn.local_keystroke({ "r" }),
            edit_user_request = fn.local_keystroke({ "e" }),
          },
          files = {
            add_current = fn.wk_keystroke({ categories.COPILOT, "b" }),
            add_all_buffers = fn.wk_keystroke({ categories.COPILOT, "B" }),
          },
          ask = fn.wk_keystroke({ categories.COPILOT, "c" }),
          new_ask = fn.wk_keystroke({ categories.COPILOT, "C" }),
          zen_mode = fn.wk_keystroke({ categories.COPILOT, "z" }),
          edit = fn.wk_keystroke({ categories.COPILOT, "e" }),
          refresh = fn.wk_keystroke({ categories.COPILOT, "r" }),
          focus = fn.wk_keystroke({ categories.COPILOT, "F" }),
          stop = fn.wk_keystroke({ categories.COPILOT, "q" }),
          select_model = fn.wk_keystroke({ categories.COPILOT, "m", "a" }),
          select_history = fn.wk_keystroke({ categories.COPILOT, "f" }),
          confirm = {
            focus_window = "<C-w>f",
            code = "c",
            resp = "r",
            input = "i",
          },
          toggle = {
            default = fn.wk_keystroke({ categories.COPILOT, "c" }),
            debug = fn.local_keystroke({ "?" }),
            selection = fn.wk_keystroke({ categories.COPILOT, "s" }),
            suggestion = fn.wk_keystroke({ categories.COPILOT, "S" }),
            repomap = fn.wk_keystroke({ categories.COPILOT, "R" }),
          },
        },
      }
    end,
    on_setup = function(c)
      require("avante").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        -- chat
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("avante.api").ask()
          end,
          desc = "toggle chat [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "C" }),
          function()
            require("avante.api").ask({ new_chat = true })
          end,
          desc = "new chat [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "f" }),
          function()
            require("avante.api").select_history()
          end,
          desc = "chat history [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "X" }),
          function()
            vim.cmd("AvanteClear")
          end,
          desc = "close last chat [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "q" }),
          function()
            require("avante.api").stop()
          end,
          desc = "stop request [avante]",
          mode = { "n", "v" },
        },
        -- actions
        {
          fn.wk_keystroke({ categories.COPILOT, "e" }),
          function()
            require("avante.api").edit()
          end,
          desc = "edit [avante]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            require("avante.api").refresh()
          end,
          desc = "refresh [avante]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "<Space>" }),
          function()
            require("avante.api").focus()
          end,
          desc = "focus sidebar [avante]",
          mode = { "n" },
        },
        -- files
        {
          fn.wk_keystroke({ categories.COPILOT, "a" }),
          function()
            require("avante.api").add_selected_file(vim.fn.expand("%"))
          end,
          desc = "add current file [avante]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "B" }),
          function()
            require("avante.api").add_buffer_files()
          end,
          desc = "add all buffer files [avante]",
          mode = { "n" },
        },
        -- toggles
        {
          fn.wk_keystroke({ categories.COPILOT, "s" }),
          function()
            require("avante").toggle.selection()
          end,
          desc = "toggle selection [avante]",
          mode = { "n" },
        },
        -- model
        {
          fn.wk_keystroke({ categories.COPILOT, "m" }),
          group = "model [avante]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "m", "a" }),
          function()
            require("avante.api").select_model()
          end,
          desc = "select model [avante]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "m", "p" }),
          function()
            local Config = require("avante.config")
            local providers = vim.tbl_keys(Config.acp_providers or {})
            table.sort(providers)

            vim.ui.select(providers, {
              prompt = "Switch ACP Provider",
              format_item = function(item)
                local current = Config.provider
                if item == current then
                  return item .. " (current)"
                end

                return item
              end,
            }, function(choice)
              if choice then
                require("avante.api").switch_provider(choice)
              end
            end)
          end,
          desc = "switch provider [avante]",
          mode = { "n" },
        },
        -- admin
        {
          fn.wk_keystroke({ categories.COPILOT, "Q" }),
          function()
            vim.cmd([[Lazy reload avante.nvim]])
          end,
          desc = "reload [avante]",
          mode = { "n", "v" },
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
          desc = "select profile for claude [avante]",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      local markview_disabled_buffers = {}

      return {
        -- {
        --   event = "User",
        --   group = "_avante_markview",
        --   pattern = "AvanteInputSubmitted",
        --   callback = function()
        --     local ok, sidebar = pcall(function()
        --       return require("avante").get()
        --     end)
        --     if not ok or not sidebar or not sidebar.containers or not sidebar.containers.result then
        --       return
        --     end
        --
        --     local bufnr = sidebar.containers.result.bufnr
        --     if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        --       pcall(require("markview.commands").disable, bufnr)
        --       markview_disabled_buffers[bufnr] = true
        --     end
        --   end,
        -- },
        -- {
        --   event = "User",
        --   group = "_avante_markview",
        --   pattern = "AvanteViewBufferUpdated",
        --   callback = function()
        --     for bufnr, _ in pairs(markview_disabled_buffers) do
        --       if vim.api.nvim_buf_is_valid(bufnr) then
        --         pcall(require("markview.commands").enable, bufnr)
        --       end
        --     end
        --     markview_disabled_buffers = {}
        --   end,
        -- },
      }
    end,
  })
end

return M
