local log = require("lvim.log")

local M = {}

--- Initialize lvim default configuration and variables
function M:init()
  lvim = vim.deepcopy(require("lvim.config.defaults"))

  vim.cmd(("colorscheme %s"):format(lvim.colorscheme))

  require("lvim.config.settings").load_defaults()

  require("keys").load_defaults()

  lvim.lsp = vim.deepcopy(require("lvim.config.lsp"))
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load()
  log:debug("Loading configuration...")

  require("config")

  require("extensions").config(self)

  require("modules").config(self)

  require("utils.setup").create_autocmds(lvim.autocommands)

  if lvim.ui.transparent_window then
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

  require("keys").setup()
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    M:load()

    require("lvim.lsp.format").setup()

    local loader = require("lvim.loader")

    loader.reload({ lvim.plugins })
  end)
end

return M
