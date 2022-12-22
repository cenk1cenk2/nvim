-- https://github.com/inkarkat/vim-UnconditionalPaste
local M = {}

local extension_name = "vim_unconditionalpaste"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "inkarkat/vim-UnconditionalPaste",
        keys = { "gp", "gP" },
      }
    end,
    legacy_setup = {
      UnconditionalPaste_no_mappings = 1,
    },
    keymaps = {
      normal_mode = {
        ["gP"] = { [[<Plug>UnconditionalPasteInlinedBefore]], { desc = "unconditionalpaste inlined before" } },
        ["gp"] = { [[<Plug>UnconditionalPasteInlinedAfter]], { desc = "unconditionalpaste inlined after" } },
      },
    },
  })
end

return M
