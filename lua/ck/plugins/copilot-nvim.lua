-- https://github.com/zbirenbaum/copilot.lua
local M = {}

M.name = "zbirenbaum/copilot.lua"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        cmd = { "Copilot" },
        dependencies = {
          {
            -- https://github.com/zbirenbaum/copilot-cmp
            "zbirenbaum/copilot-cmp",
            enabled = is_enabled(require("ck.plugins.cmp").name) and vim.tbl_contains(nvim.lsp.copilot.completion, "cmp"),
            init = function()
              local cmp = require("ck.plugins.cmp")
              table.insert(cmp.sources, 1, {
                name = "copilot",
              })

              require("ck.setup").setup_callback(cmp.name, function(c)
                c.formatting.source_names["copilot"] = "CoPi"

                return c
              end)
            end,
            config = function()
              require("copilot_cmp").setup()
            end,
          },
        },
      }
    end,
    setup = function()
      return {
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
          enabled = true,
          auto_trigger = vim.tbl_contains(nvim.lsp.copilot.completion, "inline"),
          debounce = nvim.lsp.copilot.debounce,
          keymap = {
            accept = false,
            accept_line = false,
            next = "<M-j>",
            prev = "<M-k>",
            dismiss = "<M-h>",
            accept_word = false,
          },
        },
        filetypes = nvim.lsp.copilot.filetypes,
        copilot_node_command = "node", -- Node.js version must be > 18.x
        server_opts_overrides = {},
      }
    end,
    on_setup = function(c)
      require("copilot").setup(c)
    end,
    keymaps = function()
      return {
        {
          "<M-l>",
          function()
            local autopairs = require("nvim-autopairs")
            local suggestion = require("copilot.suggestion")
            autopairs.disable()
            suggestion.accept()
            autopairs.enable()
          end,
          desc = "accept copilot suggestion",
          mode = "i",
        },
        {
          "<M-s-l>",
          function()
            local autopairs = require("nvim-autopairs")
            local suggestion = require("copilot.suggestion")
            autopairs.disable()
            suggestion.accept_line()
            autopairs.enable()
          end,
          desc = "accept copilot suggestion for line",
          mode = "i",
        },
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
