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
              local client = vim.lsp.get_clients({ name = "copilot" })
              if not client or #client == 0 then
                log:warn("No Copilot LSP client found")
                return
              end

              require("copilot-lsp.nes").request_nes(client[1])
            end
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
        {
          "<M-f>",
          function()
            log:info("Requesting NES...")
            local client = vim.lsp.get_clients({ name = "copilot" })
            if not client or #client == 0 then
              log:warn("No Copilot LSP client found")
              return
            end
            require("copilot-lsp.nes").request_nes(client[1])
          end,
          desc = "nes: request suggestion",
          mode = { "i", "n", "v" },
        },
      }
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = { "LspAttach" },
          group = "copilotlsp.nes_init",
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client or client.name ~= "copilot" then
              return
            end

            local au = vim.api.nvim_create_augroup("copilotlsp.init", { clear = true })
            require("copilot-lsp.nes").lsp_on_init(client, au)
          end,
        },
      }
    end,
  })
end

return M
