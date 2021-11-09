local M = {}

local extension_name = "package_info"

function M.config()
  local c = require "onedarker.colors"

  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {
      colors = {
        up_to_date = c.gray, -- Text color for up to date package virtual text
        outdated = c.yellow, -- Text color for outdated package virtual text
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
  }
end

function M.setup()
  local extension = require "package-info"

  extension.setup(lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings["m"] = {
    name = "+node_modules",
    s = { ':lua require("package-info").show()<CR>', "show package-info" },
    S = { ':lua require("package-info").hide()<CR>', "hide package-info" },
    u = { ':lua require("package-info").update()<CR>', "update current package" },
    d = { ':lua require("package-info").delete()<CR>', "delete current package" },
    i = { ':lua require("package-info").install()<CR>', "install packages" },
    r = { ':lua require("package-info").reinstall()<CR>', "reinstall packages" },
    c = { ':lua require("package-info").change_version()<CR>', "change version of the package" },
    m = { ":Telescope node_modules list<CR>", "node modules" },
  }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
