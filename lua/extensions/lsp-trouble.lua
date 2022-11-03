-- https://github.com/folke/trouble.nvim
local M = {}

local extension_name = "lsp_trouble"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "folke/lsp-trouble.nvim",
        config = function()
          require("utils.setup").packer_config "lsp_trouble"
        end,
        disable = not config.active,
      }
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
        previous = "k", -- preview item
        next = "j", -- next item
      },
    },
    on_setup = function(config)
      require("trouble").setup(config.setup)
    end,
    on_done = function()
      lvim.lsp_wrapper.document_diagnostics = function()
        vim.api.nvim_command "TroubleToggle document_diagnostics"
      end

      lvim.lsp_wrapper.workspace_diagnostics = function()
        vim.api.nvim_command "TroubleToggle workspace_diagnostics"
      end
    end,
  })
end

return M
