-- https://github.com/karb94/neoscroll.nvim
local M = {}

local extension_name = "neoscroll"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "karb94/neoscroll.nvim",
        event = "BufWinEnter",
        config = function()
          require("utils.setup").packer_config "neoscroll"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      -- All these keys will be mapped. Pass an empty table ({}) for no mappings
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },
      hide_cursor = false, -- Hide cursor while scrolling
      stop_eof = false, -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
    },
    on_setup = function(config)
      require("neoscroll").setup(config.setup)
    end,
  })
end

return M
