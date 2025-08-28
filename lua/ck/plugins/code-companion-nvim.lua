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
                  return 0.3
                end

                return 120
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
            claude = require("ck.plugins.code-companion-nvim-adapter-claude"),
          },
        },
        strategies = {
          chat = {
            adapter = {
              name = nvim.lsp.ai.provider.chat,
              model = nvim.lsp.ai.model.chat,
            },
            window = {
              border = nvim.ui.border,
              numberwidth = 0,
            },
            tools = {
              opts = {
                auto_submit_errors = true, -- Send any errors to the LLM automatically?
                auto_submit_success = true, -- Send any successful output to the LLM automatically?
                default_tools = { "full_stack_dev" },
              },
            },
            keymaps = {
              options = {
                modes = { n = "?" },
              },
              completion = {
                modes = { i = "<C-_>" },
              },
              send = {
                modes = {
                  n = { "<CR>", "<C-s>" },
                  i = "<C-s>",
                },
              },
              close = {
                modes = {
                  n = "<C-c>",
                  i = "<C-c>",
                },
              },
              regenerate = {
                modes = { n = fn.local_keystroke({ "r" }) },
              },
              stop = {
                modes = { n = fn.local_keystroke({ "Q" }) },
              },
              clear = {
                modes = { n = fn.local_keystroke({ "q" }) },
              },
              codeblock = {
                modes = { n = fn.local_keystroke({ "C" }) },
              },
              yank_code = {
                modes = { n = fn.local_keystroke({ "y" }) },
              },
              pin = {
                modes = { n = fn.local_keystroke({ "p" }) },
              },
              watch = {
                modes = { n = fn.local_keystroke({ "w" }) },
              },
              next_chat = {
                modes = { n = "}" },
              },
              previous_chat = {
                modes = { n = "{" },
              },
              next_header = {
                modes = { n = "]]" },
              },
              previous_header = {
                modes = { n = "[[" },
              },
              change_adapter = {
                modes = { n = fn.local_keystroke({ "a" }) },
              },
              fold_code = {
                modes = { n = fn.local_keystroke({ "z" }) },
              },
              debug = {
                modes = { n = fn.local_keystroke({ "d" }) },
              },
              system_prompt = {
                modes = { n = fn.local_keystroke({ "s" }) },
              },
              auto_tool_mode = {
                modes = { n = fn.local_keystroke({ "T" }) },
              },
              goto_file_under_cursor = {
                modes = { n = "gf" },
              },
              copilot_stats = {
                modes = { n = fn.local_keystroke({ "S" }) },
              },
              super_diff = {
                modes = { n = fn.local_keystroke({ "D" }) },
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
                modes = { n = fn.local_keystroke({ "cA" }) },
              },
            },
          },
        },
        display = {
          chat = {
            show_header_separator = true,
            show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
            fold_context = true, -- Fold context in the chat buffer?

            show_settings = true, -- Show LLM settings at the top of the chat buffer?
            show_tools_processing = true, -- Show the loading message when tools are being executed?
            show_token_count = true, -- Show the token count for each response?
            start_in_insert_mode = true, -- Open the chat buffer in insert mode?
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
          fn.wk_keystroke({ categories.COPILOT, "l" }),
          function()
            require("codecompanion").last_chat()
          end,
          desc = "select history [codecompanion]",
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
