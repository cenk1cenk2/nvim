-- https://github.com/anuvyklack/windows.nvim
local M = {}

local extension_name = "windows_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "anuvyklack/windows.nvim",
        requires = {
          "anuvyklack/middleclass",
          "anuvyklack/animation.nvim",
        },
        config = function()
          require("utils.setup").packer_config "windows_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = function()
      return {
        autowidth = { --		     |windows.autowidth|
          enable = true,
          winwidth = 10, --		      |windows.winwidth|
          filetype = { --	    |windows.autowidth.filetype|
            help = 2,
          },
        },
        ignore = { --			|windows.ignore|
          buftype = { "quickfix" },
          filetype = lvim.disabled_filetypes,
        },
        animation = {
          enable = true,
          duration = 100,
          fps = 60,
          easing = "in_out_sine",
        },
      }
    end,
    on_setup = function(config)
      require("windows").setup(config.setup)
    end,
    nvim_opts = {
      -- winwidth = 10,
      winminwidth = 0,
    },
    wk = {
      ["M"] = { ":WindowsMaximize<CR>", "maximize current window" },
      ["="] = { ":WindowsEqualize<CR>", "equalize all windows" },
    },
    autocmds = {
      {
        "VimResized",
        {
          group = "_auto_resize",
          pattern = "*",
          command = ":WindowsEqualize",
        },
      },
    },
  })
end

return M
