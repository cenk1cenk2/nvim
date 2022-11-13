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
        up_to_date = c.grey[500], -- Text color for up to date package virtual text
        outdated = c.yellow[600], -- Text color for outdated package virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = " ", -- Icon for up to date packages
          outdated = " ", -- Icon for outdated packages
        },
      },
      autostart = false, -- Whether to autostart when `package.json` is opened
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
    wk = function(config, categories)
      local package_info = config.inject.package_info

      return {
        [categories.DEPENDENCIES] = {
          name = "+modules",
          s = {
            function()
              package_info.show()
            end,
            "show package-info",
          },
          S = {
            function()
              package_info.hide()
            end,
            "hide package-info",
          },
          u = {
            function()
              package_info.update()
            end,
            "update current package",
          },
          d = {
            function()
              package_info.delete()
            end,
            "delete current package",
          },
          i = {
            function()
              package_info.install()
            end,
            "install packages",
          },
          r = {
            function()
              package_info.reinstall()
            end,
            "reinstall packages",
          },
          c = {
            function()
              package_info.change_version()
            end,
            "change version of the package",
          },
          m = { ":Telescope node_modules list<CR>", "node modules" },
        },
      }
    end,
  })
end

return M
