local M = {}

local extension_name = "vim_unconditionalpaste"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {},
    keymaps = {
      normal_mode = {
        ["gp"] = { [[<Plug>UnconditionalPasteInlinedBefore]], { noremap = false, silent = true } },
        ["gP"] = { [[<Plug>UnconditionalPasteInlinedAfter]], { noremap = false, silent = true } },
      },
    },
  }
end

function M.setup()
  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  vim.g.UnconditionalPaste_no_mappings = 1

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
