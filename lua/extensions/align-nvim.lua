local M = {}

local setup = require "utils.setup"

local extension_name = "align_nvim"

function M.config()
  setup.define_extension(extension_name, true, {
    on_config_done = nil,
    setup = {},
    keymaps = {
      ["gas"] = {
        { "visual_mode" },
        function()
          require("align").align_to_string(false, true, true)
        end,
        { desc = "align to string" },
      },
      ["gar"] = {
        { "visual_mode" },
        function()
          require("align").align_to_string(true, true, true)
        end,
        { desc = "align to regex" },
      },
      ["gac"] = {
        { "visual_mode" },
        function()
          require("align").align_to_char(1, true)
        end,
        { desc = "align to char" },
      },
    },
  })
end

function M.setup()
  local config = setup.get_config(extension_name)

  setup.load_mappings(config.keymaps)

  setup.on_setup_done(config)
end

return M
