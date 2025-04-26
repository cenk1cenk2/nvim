-- https://github.com/copilotlsp-nvim/copilot-lsp
local M = {}

M.name = "copilotlsp-nvim/copilot-lsp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "copilotlsp-nvim/copilot-lsp",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    on_done = function()
      vim.g.copilot_nes_debounce = nvim.lsp.copilot.nes.debounce
      -- https://github.com/copilotlsp-nvim/copilot-lsp/issues/8
      vim.g.copilot_nes_auto_suggest = nvim.lsp.copilot.nes.auto_suggest
      vim.lsp.enable("copilot_ls")
    end,
    keymaps = function()
      return {
        {
          "<M-s>",
          function()
            local nes = require("copilot-lsp.nes")

            local clients = vim.lsp.get_clients({
              bufnr = vim.api.nvim_get_current_buf(),
              name = "copilot_ls",
            })
            if #clients == 0 then
              return
            end

            nes.request_nes(clients[1])
          end,
          desc = "nes: suggest",
          mode = { "i", "n", "v" },
        },
        {
          "<M-d>",
          function()
            local nes = require("copilot-lsp.nes")

            nes.walk_cursor_start_edit()
          end,
          desc = "nes: jump to start",
          mode = { "i", "n", "v" },
        },
        {
          "<M-a>",
          function()
            local nes = require("copilot-lsp.nes")
            -- Try to jump to the start of the suggestion edit.
            -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
            -- local _ = nes.walk_cursor_start_edit() or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
            -- local _ = nes.apply_pending_nes() and nes.walk_cursor_end_edit()
            nes.apply_pending_nes()
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
      }
    end,
  })
end

return M
