local log = require("ck.log")

local M = {}

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load()
  log:debug("Starting to load configuration...")

  _G.nvim = require("ck.config.defaults")
  _G.nvim.lsp = require("ck.config.lsp")
  require("ck.override")

  require("ck.config.settings").setup()

  M.load_colorscheme()

  require("ck.keys").setup()

  require("ck.plugins").config()

  require("ck.modules").config()
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    log:info("Reloading configuration...")

    require_clean("ck.config"):load()

    local loader = require_clean("ck.loader")

    loader.reload()

    log:info("Configuration reloaded!")
  end)
end

function M.load_colorscheme()
  vim.cmd(("colorscheme %s"):format(nvim.colorscheme))

  if nvim.ui.transparent then
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
end

return M
