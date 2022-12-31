-- https://github.com/lvimuser/lsp-inlayhints.nvim
local M = {}

local extension_name = "lsp_inlayhits_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "lvimuser/lsp-inlayhints.nvim",
        -- branch = "anticonceal",
        event = "BufReadPost",
      }
    end,
    setup = {
      inlay_hints = {
        parameter_hints = {
          show = true,
          prefix = lvim.icons.ui.ChevronShortLeft .. " ",
          separator = " " .. lvim.icons.ui.Ellipsis .. " ",
          remove_colon_start = false,
          remove_colon_end = true,
        },
        type_hints = {
          -- type and other hints
          show = true,
          prefix = "",
          separator = " " .. lvim.icons.ui.Ellipsis .. " ",
          remove_colon_start = false,
          remove_colon_end = false,
        },
        only_current_line = false,
        -- separator between types and parameter hints. Note that type hints are
        -- shown before parameter
        labels_separator = "  ",
        -- whether to align to the length of the longest line in the file
        max_len_align = false,
        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,
        -- highlight group
        highlight = "LspInlayHint",
      },
      enabled_at_startup = true,
      debug_mode = false,
    },
    on_setup = function(config)
      require("lsp-inlayhints").setup(config.setup)
    end,
    on_done = function()
      vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
      vim.api.nvim_create_autocmd("LspAttach", {
        group = "LspAttach_inlayhints",
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end

          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,
      })
    end,
    wk = function(_, categories)
      return {
        [categories.LSP] = {
          ["t"] = {
            function()
              require("lsp-inlayhints").toggle()
            end,
            "toggle inlay hints",
          },
          ["T"] = {
            function()
              require("lsp-inlayhints").reset()
            end,
            "reset inlay hints",
          },
        },
      }
    end,
  })
end

return M
