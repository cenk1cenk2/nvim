-- https://github.com/zbirenbaum/copilot.lua
local M = {}

M.name = "zbirenbaum/copilot.lua"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.provider.completion == "copilot" or nvim.lsp.ai.provider.chat == "copilot", {
    plugin = function()
      ---@type Plugin
      return {
        "zbirenbaum/copilot.lua",
        event = { "InsertEnter" },
        cmd = { "Copilot" },
        dependencies = {
          {
            -- https://github.com/fang2hou/blink-copilot
            "fang2hou/blink-copilot",
            enabled = is_enabled(require("ck.plugins.blink-cmp").name) and vim.tbl_contains(nvim.lsp.ai.completion.provider, "cmp"),
            init = function()
              require("ck.setup").setup_callback(require("ck.plugins.blink-cmp").name, function(c)
                c.sources.providers.copilot = {
                  name = "copilot",
                  module = "blink-copilot",
                  score_offset = 100,
                  async = true,
                  opts = {
                    kind_icon = nvim.ui.icons.misc.Robot,
                  },
                }

                local cb = c.sources.default

                c.sources.default = function(ctx)
                  return vim.list_extend({ "copilot" }, cb(ctx))
                end

                return c
              end)
            end,
          },
        },
      }
    end,
    setup = function()
      return {
        copilot_model = nvim.lsp.ai.model.completion,
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.25,
          },
        },
        suggestion = {
          enabled = nvim.lsp.ai.provider.completion == "copilot",
          -- this is now handled by nvim.lsp.inline_completion
          -- auto_trigger = vim.tbl_contains(nvim.lsp.ai.completion.provider, "inline"),
          auto_trigger = false,
          debounce = nvim.lsp.ai.copilot.debounce,
          keymap = {
            accept = false,
            accept_line = false,
            next = false,
            prev = false,
            dismiss = false,
            accept_word = false,
          },
        },
        filetypes = nvim.lsp.ai.copilot.filetypes,
        copilot_node_command = "node", -- Node.js version must be > 18.x
        server_opts_overrides = {},
      }
    end,
    on_setup = function(c)
      require("copilot").setup(c)
    end,
    keymaps = function()
      return {
        -- {
        --   "<M-l>",
        --   function()
        --     local autopairs = require("nvim-autopairs")
        --     local suggestion = require("copilot.suggestion")
        --     autopairs.disable()
        --     suggestion.accept({})
        --     autopairs.enable()
        --   end,
        --   desc = "accept copilot suggestion",
        --   mode = "i",
        -- },
        -- {
        --   "<M-s-l>",
        --   function()
        --     local autopairs = require("nvim-autopairs")
        --     local suggestion = require("copilot.suggestion")
        --     autopairs.disable()
        --     suggestion.accept_line()
        --     autopairs.enable()
        --   end,
        --   desc = "accept copilot suggestion for line",
        --   mode = "i",
        -- },
      }
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "P" }),
          function()
            vim.cmd([[Copilot panel]])
          end,
          desc = "copilot panel",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "S" }),
          function()
            vim.cmd([[Copilot status]])
          end,
          desc = "copilot status",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t" }),
          function()
            vim.cmd([[Copilot toggle]])
          end,
          desc = "copilot toggle",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "s" }),
          function()
            vim.cmd([[Copilot suggestion]])
          end,
          desc = "copilot suggestion",
        },
      }
    end,
  })
end

return M
