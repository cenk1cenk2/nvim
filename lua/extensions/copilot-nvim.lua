-- https://github.com/zbirenbaum/copilot.lua
local M = {}

local extension_name = "zbirenbaum/copilot.lua"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
          markdown = false,
          help = false,
          gitcommit = false,
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
    on_setup = function(config)
      require("copilot").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        ["C"] = {
          ["p"] = { ":Copilot panel<CR>", "copilot panel" },
          ["S"] = { ":Copilot status<CR>", "copilot status" },
          ["t"] = { ":Copilot toggle<CR>", "copilot toggle" },
          ["s"] = { ":Copilot suggestion<CR>", "copilot suggestion" },
        },
      }
    end,
  })
end

return M
