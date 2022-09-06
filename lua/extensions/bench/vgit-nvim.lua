-- {
--   "tanvirtin/vgit.nvim",
--   config = function()
--     require("extensions.vgit-nvim").setup()
--   end,
--   disable = not lvim.extensions.vgit_nvim.active,
-- },
local M = {}

local extension_name = "vgit_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {
      keymaps = {},

      settings = {
        live_blame = {
          enabled = false,
        },
        live_gutter = {
          enabled = false,
        },
        scene = {
          diff_preference = "unified",
        },
        authorship_code_lens = {
          enabled = false,
        },
      },
    },
  }
end

function M.setup()
  local extension = require "vgit"

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
