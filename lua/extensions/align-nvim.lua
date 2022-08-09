local M = {}

local extension_name = "align_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {},
    keymaps = {
      visual_mode = {
        ["gas"] = {
          function()
            require("align").align_to_string(false, true, true)
          end,
          { desc = "align to string" },
        },
        ["gar"] = {
          function()
            require("align").align_to_string(true, true, true)
          end,
          { desc = "align to regex" },
        },
        ["gac"] = {
          function()
            require("align").align_to_char(1, true)
          end,
          { desc = "align to char" },
        },
      },
    },
  }
end

function M.setup()
  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
