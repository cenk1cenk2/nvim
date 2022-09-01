local M = {}

local extension_name = "git_conflict_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      default_mappings = false, -- disable buffer local mapping created by this plugin
      disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = { -- They must have background color, otherwise the default color will be used
        incoming = "DiffText",
        current = "DiffAdd",
      },
    },
    keymaps = {
      normal_mode = {
        ["co"] = { ":GitConflictChooseOurs<CR>", { desc = "Conflict - Choose Ours" } },
        ["ct"] = { ":GitConflictChooseTheirs<CR>", { desc = "Conflict - Choose Theirs" } },
        ["cb"] = { ":GitConflictChooseBoth<CR>", { desc = "Conflict - Choose Both" } },
        ["c0"] = { ":GitConflictChooseNone<CR>", { desc = "Conflict - Choose None" } },
        ["]n"] = { ":GitConflictNextConflict<CR>", { desc = "Conflict - Next" } },
        ["[n"] = { ":GitConflictPrevConflict<CR>", { desc = "Conflict - Previous" } },
        ["cq"] = { ":GitConflictListQf<CR>", { desc = "Conflict - Quick Fix" } },
      },
    },
  }
end

function M.setup()
  local extension = require "git-conflict"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
