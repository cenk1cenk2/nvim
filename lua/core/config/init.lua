local log = require("core.log")

local M = {}

--- Initialize nvim default configuration and variables
function M:init()
  nvim = vim.deepcopy(require("core.config.defaults"))

  vim.cmd(("colorscheme %s"):format(nvim.colorscheme))

  require("core.config.settings").load_defaults()

  require("core.keys").load_defaults()

  nvim.lsp = vim.deepcopy(require("core.config.lsp"))
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load()
  log:debug("Loading configuration...")

  require("config")

  require("extensions").config(self)

  require("modules").config(self)

  require("setup").create_autocmds(nvim.autocommands)

  if nvim.ui.transparent_window then
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        local hl_groups = {
          "Normal",
          "SignColumn",
          "NormalNC",
          "NvimTreeNormal",
          "EndOfBuffer",
          "MsgArea",
        }
        for _, name in ipairs(hl_groups) do
          vim.cmd(string.format("highlight %s ctermbg=none guibg=none", name))
        end
      end,
    })
    vim.opt.fillchars = "eob: "
  end

  require("core.keys").setup()
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    M:load()

    require("core.lsp.format").setup()

    local loader = require("core.loader")

    loader.reload({ nvim.plugins })
  end)
end

return M
