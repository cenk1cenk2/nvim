-- https://github.com/ThePrimeagen/harpoon
local M = {}

local extension_name = "harpoon"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "ThePrimeagen/harpoon",
        config = function()
          require("utils.setup").packer_config "harpoon"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        harpoon = require "harpoon",
        harpoon_mark = require "harpoon.mark",
        harpoon_ui = require "harpoon.ui",
        telescope = require "telescope",
      }
    end,
    setup = function()
      return {
        -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
        save_on_toggle = false,

        -- saves the harpoon file upon every change. disabling is unrecommended.
        save_on_change = true,

        -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
        enter_on_sendcmd = false,

        -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
        tmux_autoclose_windows = false,

        -- filetypes that you want to prevent from adding to the harpoon list menu.
        excluded_filetypes = lvim.disabled_filetypes,

        -- set marks specific to each git branch inside git repository
        mark_branch = false,
      }
    end,
    on_setup = function(config)
      require("harpoon").setup(config.setup)
    end,
    on_done = function(config)
      config.inject.telescope.load_extension "harpoon"
    end,
    wk = function(config, categories)
      local mark = config.inject.harpoon_mark
      local ui = config.inject.harpoon_ui

      return {
        [categories.BOOKMARKS] = {
          ["f"] = { ":Telescope harpoon marks<CR>", "find marks" },
          ["m"] = {
            function()
              mark.toggle_file()
            end,
            "toggle mark",
          },
          ["n"] = {
            function()
              ui.nav_next()
            end,
            "next mark",
          },
          ["p"] = {
            function()
              ui.nav_prev()
            end,
            "previous mark",
          },
          ["q"] = {
            function()
              mark.to_quickfix_list()
              vim.cmd "QuickFixToggle"
            end,
            "send to quickfix",
          },
        },
      }
    end,
  })
end

return M
