local M = {}

local extension_name = "lsp_trouble"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
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
  }
end

function M.setup()
  local extension = require "trouble"

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings["l"]["d"] = { ":LspTroubleDocumentToggle<CR>", "show all document diagnostics" }
  lvim.builtin.which_key.mappings["l"]["D"] = { ":LspTroubleWorkspaceToggle<CR>", "show all workspace diagnostics" }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
