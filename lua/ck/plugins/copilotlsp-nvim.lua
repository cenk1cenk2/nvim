-- https://github.com/copilotlsp-nvim/copilot-lsp
local M = {}

M.name = "copilotlsp-nvim/copilot-lsp"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "copilotlsp-nvim/copilot-lsp",
        event = { "InsertEnter" },
      }
    end,
    legacy_setup = {
      copilot_nes_debounce = 500,
    },
    keymaps = function()
      return {
        {
          "<M-l>",
          function()
            -- Try to jump to the start of the suggestion edit.
            -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
            local _ = require("copilot-lsp.nes").walk_cursor_start_edit() or (require("copilot-lsp.nes").apply_pending_nes() and require("copilot-lsp.nes").walk_cursor_end_edit())
          end,
          desc = "nes: just to next start of edit",
          mode = "i",
        },
      }
    end,
  })
end

return M
