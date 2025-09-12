-- https://github.com/copilotlsp-nvim/copilot-lsp
local M = {}

M.name = "copilotlsp-nvim/copilot-lsp"

local log = require("ck.log")

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.copilot.nes.enabled, {
    plugin = function()
      ---@type Plugin
      return {
        "copilotlsp-nvim/copilot-lsp",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        nes = {
          move_count_treshold = 3,
        },
      }
    end,
    on_setup = function(config)
      vim.g.copilot_nes_debounce = nvim.lsp.ai.copilot.nes.debounce
      -- https://github.com/copilotlsp-nvim/copilot-lsp/issues/8
      vim.g.copilot_nes_auto_suggest = nvim.lsp.ai.copilot.nes.auto_suggest

      require("copilot-lsp").setup(config)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<M-d>",
          function()
            require("copilot-lsp.nes").clear()
          end,
          desc = "nes: abort",
          mode = { "i", "n", "v" },
        },
        {
          "<M-s>",
          function()
            require("copilot-lsp.nes").walk_cursor_start_edit()
          end,
          desc = "nes: jump to start",
          mode = { "i", "n", "v" },
        },
        {
          "<M-a>",
          function()
            -- local _ = nes.walk_cursor_start_edit() or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
            -- local _ = nes.apply_pending_nes() and nes.walk_cursor_end_edit()
            local applied = require("copilot-lsp.nes").apply_pending_nes()
            if not applied then
              log:info("Requesting NES...")
              require("copilot-lsp.nes").request_nes("copilot")
            end
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
        {
          "<M-r>",
          function()
            require("copilot-lsp.nes").restore_suggestion()
          end,
          desc = "nes: restore suggestion",
          mode = { "i", "n", "v" },
        },
      }
    end,
  })
end

return M
