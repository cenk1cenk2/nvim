-- https://github.com/zbirenbaum/copilot.lua
local M = {}

M.name = "zbirenbaum/copilot.lua"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        cmd = { "Copilot" },
      }
    end,
    setup = function()
      return {
        panel = {
          enabled = true,
          auto_refresh = false,
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
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            next = "<M-j>",
            prev = "<M-k>",
            dismiss = "<M-h>",
            accept_word = false,
            accept_line = false,
          },
        },
        filetypes = {
          yaml = false,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = "node", -- Node.js version must be > 18.x
        server_opts_overrides = {},
      }
    end,
    on_setup = function(c)
      require("copilot").setup(c)
    end,
    on_done = function()
      -- local autopairs = require("nvim-autopairs")
      -- local suggestion = require("copilot.suggestion")
      -- vim.keymap.set("i", "<M-l>", function()
      --   autopairs.disable()
      --   suggestion.accept()
      --   autopairs.enable()
      -- end, { desc = "Accept Copilot suggestion" })
    end,
    wk = function(_, categories, fn)
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
