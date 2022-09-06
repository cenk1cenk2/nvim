-- https://github.com/lukas-reineke/indent-blankline.nvim
local M = {}

local extension_name = "lsp_inlayhits_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "lvimuser/lsp-inlayhints.nvim",
        config = function()
          require("utils.setup").packer_config "lsp_inlayhits_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        inlay_hints = require "lsp-inlayhints",
      }
    end,
    setup = {
      inlay_hints = {
        parameter_hints = {
          show = true,
          prefix = "<- ",
          separator = ", ",
          remove_colon_start = false,
          remove_colon_end = true,
        },
        type_hints = {
          -- type and other hints
          show = true,
          prefix = "",
          separator = ", ",
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
    wk = function(config)
      local inlay_hints = config.inject.inlay_hints

      return {
        ["l"] = {
          ["t"] = { inlay_hints.toggle, "toggle inlay hints" },
        },
      }
    end,
  })
end

return M
