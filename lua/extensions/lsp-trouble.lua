-- https://github.com/folke/trouble.nvim
local M = {}

local extension_name = "lsp_trouble"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "folke/lsp-trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "LspTrouble",
        "Trouble",
      })

      lvim.lsp.wrapper.document_diagnostics = function()
        require("trouble").toggle("document_diagnostics")
      end

      lvim.lsp.wrapper.workspace_diagnostics = function()
        require("trouble").toggle("workspace_diagnostics")
      end
    end,
    setup = {
      action_keys = { -- key mappings for actions in the trouble list
        close = "q", -- close the list
        refresh = "r", -- manually refresh
        jump = "<cr>", -- jump to the diagnostic or open / close folds
        toggle_mode = "m", -- toggle between "workspace" and "document" mode
        toggle_preview = "P", -- toggle auto_preview
        preview = "p", -- preview the diagnostic location
        close_folds = "zc", -- close all folds
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        open_folds = "zo", -- open all folds
        previous = "p", -- preview item
        next = "n", -- next item
      },
    },
    on_setup = function(config)
      require("trouble").setup(config.setup)
    end,
  })
end

return M
