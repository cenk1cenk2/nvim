-- https://github.com/Wansmer/sibling-swap.nvim
local M = {}

local extension_name = "sibling_swap_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "Wansmer/sibling-swap.nvim",
        config = function()
          require("utils.setup").packer_config "sibling_swap_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = function()
      return {
        use_default_keymaps = true,
        keymaps = {
          ["LL"] = "swap_with_right",
          ["HH"] = "swap_with_left",
          ["LLL"] = "swap_with_right_with_opp",
          ["HHH"] = "swap_with_left_with_opp",
        },
        ignore_injected_langs = false,
      }
    end,
    on_setup = function(config)
      require("sibling-swap").setup(config.setup)
    end,
  })
end

return M
