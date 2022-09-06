-- https://github.com/wesQ3/vim-windowswap
local M = {}

local extension_name = "vim_windowswap"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "wesQ3/vim-windowswap",
        config = function()
          require("utils.setup").packer_config "vim_windowswap"
        end,
        disable = not config.active,
      }
    end,
    legacy_setup = {
      windowswap_map_keys = 0,
    },
    wk = {
      ["W"] = { ":call WindowSwap#EasyWindowSwap()<CR>", "move window" },
    },
  })
end

return M
