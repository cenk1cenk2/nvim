-- https://github.com/milanglacier/minuet-ai.nvim
local M = {}

local log = require("ck.log")

M.name = "milanglacier/minuet-ai.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.copilot.completion.provider, "minuet"), {
    plugin = function()
      ---@type Plugin
      return {
        "milanglacier/minuet-ai.nvim",
        event = { "LspAttach", "BufReadPre", "BufNewFile", "FileType", "InsertEnter" },
        dependencies = {
          -- TODO: this seems promising revisit this project when it is completed
          {
            -- https://github.com/Davidyz/VectorCode
            "Davidyz/VectorCode",
            cond = nvim.lsp.ai.completion.vectorcode.enabled == true,
            build = { "pipx install vectorcode[lsp]", "pipx upgrade vectorcode[lsp]" },
          },
        },
      }
    end,
    setup = function()
      local provider = nvim.lsp.ai.provider.completion
      if nvim.lsp.ai.provider.completion == "ai.kilic.dev" then
        provider = "openai_fim_compatible"
      end

      return {
        notify = nvim.lsp.ai.debug and "debug" or "error",
        provider = provider,
        n_completions = nvim.lsp.ai.completion.number_of_completions,
        context_window = nvim.lsp.ai.completion.context_window,
        context_ratio = 0.75,
        throttle = 500,
        debounce = 100,
        request_timeout = 5,
        add_single_line_entry = false,
        after_cursor_filter_length = nvim.lsp.ai.completion.line_limit,
        provider_options = {
          openai_fim_compatible = {
            api_key = "AI_KILIC_DEV_API_KEY",
            name = "Ollama",
            end_point = "https://api.ai.kilic.dev/v1/completions",
            model = nvim.lsp.ai.model.completion,
            stream = true,
            request_timeout = 30,
            template = {
              -- https://platform.openai.com/docs/api-reference/completions/create
              -- https://api-docs.deepseek.com/api/create-completion
              prompt = function(prefix, suffix)
                if not nvim.lsp.ai.completion.vectorcode.enabled then
                  return prefix .. suffix
                end

                local cacher = require("vectorcode.cacher.lsp")

                local message = nvim.lsp.ai.completion.prompt

                local result = cacher.query_from_cache(0)
                for _, file in ipairs(result) do
                  message = message .. nvim.lsp.ai.completion.fim.file .. file.path .. "\n" .. file.document
                end

                if nvim.lsp.ai.debug then
                  log:info(
                    "Cacher returns files: %s",
                    vim.tbl_map(function(file)
                      return file.path
                    end, result)
                  )
                end

                return message .. nvim.lsp.ai.completion.fim.prefix .. prefix .. nvim.lsp.ai.completion.fim.suffix .. suffix .. nvim.lsp.ai.completion.fim.middle
              end,
              suffix = false,
            },
            optional = nvim.lsp.ai.completion.options,
          },
        },
        blink = {
          enable_auto_complete = false,
        },
        virtualtext = {
          auto_trigger_ft = nvim.lsp.ai.filetypes.enabled,
          auto_trigger_ignore_ft = nvim.lsp.ai.filetypes.ignored,
          keymap = {
            next = "<M-j>",
            prev = "<M-k>",
            dismiss = "<M-h>",
            accept = "<M-l>",
            accept_line = "<M-o>",
            accept_n_lines = nil,
          },
          show_on_completion_menu = true,
        },
      }
    end,
    on_setup = function(c)
      ---@module "vectorcode"
      local ok, vectorcode = pcall(require, "vectorcode")
      if ok then
        vectorcode.setup({
          n_query = nvim.lsp.ai.completion.vectorcode.number_of_files,
          async_backend = "lsp",
          on_setup = {
            update = false,
            lsp = false,
          },
        })
      end

      require("minuet").setup(c)
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = { "LspAttach" },
          group = "__completion",
          callback = function(event)
            if not nvim.lsp.ai.completion.vectorcode.enabled then
              return
            end

            --- @module "vectorcode.cacher.lsp"
            local cacher = require("vectorcode.cacher.lsp")

            cacher.async_check("config", function()
              cacher.register_buffer(event.buf, {
                notify = nvim.lsp.ai.debug,
                run_on_register = true,
                events = { "BufReadPost", "BufWritePost", "InsertLeave" },
                debounce = 15,
              })
            end, nil)
          end,
        },
      }
    end,
  })
end

return M
