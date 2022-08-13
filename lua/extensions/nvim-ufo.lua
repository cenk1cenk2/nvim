local M = {}

local extension_name = "nvim_ufo"

function M.config()
  local ufo_ok, ufo = pcall(require, "ufo")

  if not ufo_ok then
    lvim.extensions[extension_name] = {
      active = true,
    }

    return
  end

  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      normal_mode = {
        ["zR"] = { ufo.openAllFolds, { desc = "open all folds - ufo" } },
        ["zM"] = { ufo.closeAllFolds, { desc = "close all folds - ufo" } },
      },
    },
    setup = {
      provider_selector = function(bufnr, filetype, _)
        return { "treesitter", "indent" }
      end,
    },
  }
end

function M.setup()
  local extension = require "ufo"
  extension.setup(lvim.extensions[extension_name].setup)
  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  -- vim.o.foldcolumn = "1"
  vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true
  vim.o.foldexpr = "manul"

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
