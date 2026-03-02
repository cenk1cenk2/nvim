-- https://github.com/copilotlsp-nvim/copilot-lsp
local M = {}

local log = require("ck.log")

M.name = "copilotlsp-nvim/copilot-lsp"

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
          move_count_threshold = 3,
        },
      }
    end,
    on_init = function()
      vim.g.copilot_nes_debounce = nvim.lsp.ai.copilot.nes.debounce
    end,
    on_setup = function(config)
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
            local applied = require("copilot-lsp.nes").apply_pending_nes()
            if not applied then
              log:info("Requesting NES...")
              require("copilot-lsp.nes").request()
            end
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
        {
          "<M-r>",
          function()
            require("copilot-lsp.nes").request()
          end,
          desc = "nes: request suggestion",
          mode = { "i", "n", "v" },
        },
      }
    end,
  })
end

return M
