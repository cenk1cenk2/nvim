local utils = require("lvim.utils")
local Log = require("lvim.core.log")

local M = {}

--- Initialize lvim default configuration and variables
function M:init()
  lvim = vim.deepcopy(require("lvim.config.defaults"))

  require("lvim.config.settings").load_defaults()

  require("lvim.keymappings").load_defaults()

  lvim.lsp = vim.deepcopy(require("lvim.config.lsp"))
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:load()
  Log:debug("Loading configuration...")

  require("config")

  require("extensions").config(self)

  require("modules").config(self)

  require("utils.setup").define_autocmds(lvim.autocommands)

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

  vim.g.mapleader = (lvim.leader == "space" and " ") or lvim.leader

  require("lvim.keymappings").load(lvim.keys)
end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
function M:reload()
  vim.schedule(function()
    require_clean("lvim.utils.hooks").run_pre_reload()

    M:load()

    require("lvim.lsp.format").configure_format_on_save()

    local plugin_loader = require("lvim.plugin-loader")

    plugin_loader.reload({ lvim.plugins })

    require_clean("lvim.utils.hooks").run_post_reload()
  end)
end

return M
