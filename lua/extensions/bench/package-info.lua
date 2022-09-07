-- https://github.com/vuki656/package-info.nvim
local M = {}

local c = require "onedarker.colors"

local extension_name = "package_info"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "vuki656/package-info.nvim",
        requires = "MunifTanjim/nui.nvim",
        config = function()
          require("utils.setup").packer_config "package_info"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        package_info = require "package-info",
      }
    end,
    setup = {
      colors = {
        up_to_date = c.grey[600], -- Text color for up to date package virtual text
        outdated = c.yellow[600], -- Text color for outdated package virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = " ", -- Icon for up to date packages
          outdated = " ", -- Icon for outdated packages
        },
      },
      autostart = true, -- Whether to autostart when `package.json` is opened
      hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
      hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
      -- Can be `npm` or `yarn`. Used for `delete`, `install` etc...
      -- The plugin will try to auto-detect the package manager based on
      -- `yarn.lock` or `package-lock.json`. If none are found it will use the
      -- provided one, if nothing is provided it will use `yarn`
      package_manager = "yarn",
    },
    on_setup = function(config)
      require("package-info").setup(config.setup)
    end,
    wk = function(config)
      local package_info = config.inject.package_info

      return {
        ["N"] = {
          name = "+modules",
          s = { package_info.show, "show package-info" },
          S = { package_info.hide, "hide package-info" },
          u = { package_info.update, "update current package" },
          d = { package_info.delete, "delete current package" },
          i = { package_info.install, "install packages" },
          r = { package_info.reinstall, "reinstall packages" },
          c = { package_info.change_version, "change version of the package" },
          m = { ":Telescope node_modules list<CR>", "node modules" },
        },
      }
    end,
  })
end

return M