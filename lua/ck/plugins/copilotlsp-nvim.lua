-- https://github.com/copilotlsp-nvim/copilot-lsp
local M = {}

M.name = "copilotlsp-nvim/copilot-lsp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        -- "copilotlsp-nvim/copilot-lsp",
        -- TODO: while the given merge request is open
        -- https://github.com/copilotlsp-nvim/copilot-lsp/pull/37
        "bassamsdata/copilot-lsp",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      vim.g.copilot_nes_debounce = nvim.lsp.ai.copilot.nes.debounce
      -- https://github.com/copilotlsp-nvim/copilot-lsp/issues/8
      vim.g.copilot_nes_auto_suggest = nvim.lsp.ai.copilot.nes.auto_suggest

      require("copilot-lsp").setup(config)
    end,
    on_done = function()
      vim.lsp.config("copilot_ls", {
        settings = {
          github = {
            copilot = {
              selectedCompletionModel = nvim.lsp.ai.copilot.completion.model,
            },
          },
        },
      })
      vim.lsp.enable("copilot_ls")
    end,
    keymaps = function()
      return {
        {
          "<M-d>",
          function()
            require("copilot-lsp.nes.ui")._clear_current_suggestion()
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
            require("copilot-lsp.nes").apply_pending_nes()
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
      }
    end,
  })
end

return M
