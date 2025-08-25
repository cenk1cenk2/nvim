-- https://github.com/yetone/avante.nvim
local M = {}

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
        },
      }
    end,
    configure = function(_, fn)
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

      ---@type avante.Config
      return {
        debug = nvim.lsp.ai.debug,
        provider = nvim.lsp.ai.provider.chat,
        providers = {
          copilot = {
            model = nvim.lsp.ai.model.chat,
          },
          claude = {
            endpoint = "https://api.anthropic.com",
            model = nvim.lsp.ai.model.chat,
          },
          -- Ollama API Documentation https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-completion
          ["ai.kilic.dev"] = {
            __inherited_from = "ollama",
            api_key_name = "AI_KILIC_DEV_API_KEY",
            endpoint = "https://api.ai.kilic.dev",
            parse_curl_args = function(self, prompt)
              local Ollama = require("avante.providers").ollama
              local args = Ollama.parse_curl_args(self, prompt)

              args.headers["Authorization"] = "Bearer " .. (os.getenv(self.api_key_name) or "")

              return args
            end,
            model = nvim.lsp.ai.model.chat,
            stream = true, -- Optional
            -- https://github.com/ollama/ollama/blob/main/docs/modelfile.md#parameter
            extra_request_body = {
              options = nvim.lsp.ai.chat.options,
            },
          },
        },
        web_search_engine = {
          provider = "google",
        },
        rag_service = {
          enabled = nvim.lsp.ai.chat.rag,
          host_mount = os.getenv("HOME"),
          --- NOTE: api key is causing a problem so we are using the open ai client
          provider = "openai",
          endpoint = "https://api.ai.kilic.dev/v1",
          -- llm_model = nvim.lsp.ai.model.completion,
          --- NOTE: this should be an openai model matching cause of pydantic
          llm_model = "o1",
          --- NOTE: this should be an openai model matching cause of pydantic
          embed_model = "text-embedding-3-small",
          -- embed_model = nvim.lsp.ai.model.embed,
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
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = fn.local_keystroke({ "c", "o" }),
            theirs = fn.local_keystroke({ "c", "t" }),
            all_theirs = fn.local_keystroke({ "a", "t" }),
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
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          sidebar = {
            apply_all = fn.local_keystroke({ "A" }),
            apply_cursor = fn.local_keystroke({ "a" }),
            switch_windows = "<C-n>",
            reverse_switch_windows = "<C-p>",
            remove_file = fn.local_keystroke({ "x" }),
            add_file = fn.local_keystroke({ "f" }),
            close = { "<C-c><C-c>" },
          },
          files = {
            add_current = fn.wk_keystroke({ categories.COPILOT, "b" }),
          },
          ask = fn.wk_keystroke({ categories.COPILOT, "c" }),
          edit = fn.wk_keystroke({ categories.COPILOT, "e" }),
          refresh = fn.wk_keystroke({ categories.COPILOT, "r" }),
          focus = fn.wk_keystroke({ categories.COPILOT, "f" }),
          toggle = {
            debug = fn.wk_keystroke({ categories.COPILOT, "A" }),
            hint = fn.wk_keystroke({ categories.COPILOT, "a" }),
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
        {
          fn.wk_keystroke({ categories.COPILOT, "q" }),
          function()
            vim.cmd("AvanteClear")
          end,
          desc = "clear [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "Q" }),
          function()
            require("avante.api").stop()
          end,
          desc = "stop [avante]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "f" }),
          function()
            require("avante.api").select_history()
          end,
          desc = "select history [avante]",
          mode = { "n", "v" },
        },
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
          desc = "toggle chat with new [avante]",
          mode = { "n", "v" },
        },
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
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({
          "Avante",
          "AvanteInput",
        }),
      }
    end,
  })
end

return M
