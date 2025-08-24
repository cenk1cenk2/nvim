-- https://github.com/greggh/claude-code.nvim
local M = {}

M.name = "greggh/claude-code.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.chat.provider, "claude"), {
    plugin = function()
      ---@type Plugin
      return {
        "greggh/claude-code.nvim",
      }
    end,
    setup = function()
      return {
        window = {
          split_ratio = 0.25, -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
          position = "vertical", -- Position of the window: "botright", "topleft", "vertical", "float", etc.
          enter_insert = true, -- Whether to enter insert mode when opening Claude Code
          hide_numbers = true, -- Hide line numbers in the terminal window
          hide_signcolumn = true, -- Hide the sign column in the terminal window
        },
        keymaps = {
          toggle = {
            normal = false, -- Normal mode keymap for toggling Claude Code, false to disable
            terminal = "<C-q>", -- Terminal mode keymap for toggling Claude Code, false to disable
            variants = {
              continue = false, -- Normal mode keymap for Claude Code with continue flag
              verbose = false, -- Normal mode keymap for Claude Code with verbose flag
            },
          },
          window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
          scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
        },
      }
    end,
    on_setup = function(config)
      require("claude-code").setup(config)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("claude-code").toggle()
          end,
          desc = "chat [claude-code]",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

return M
