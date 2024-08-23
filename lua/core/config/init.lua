local log = require("core.log")

local M = {}

--- Initialize nvim default configuration and variables
function M:init()
  nvim = vim.deepcopy(require("core.config.defaults"))

  require("core.config.settings").load_defaults()

  M.load_colorscheme()

  nvim.lsp = vim.deepcopy(require("core.config.lsp"))
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load()
  log:debug("Loading configuration...")

  require("config")

  require("core.keys").setup()

  require("extensions").config()

  require("modules").config()
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

function M.load_colorscheme()
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

  vim.cmd(("colorscheme %s"):format(nvim.colorscheme))
end

return M
