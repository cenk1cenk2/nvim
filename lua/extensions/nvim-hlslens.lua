local M = {}

local extension_name = "nvim_hlslens"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      calm_down = true,
      nearest_only = true,
      nearest_float_when = "always",
    },
  }
end

function M.setup()
  local extension = require "hlslens"

  if lvim.extensions.nvim_scrollbar and lvim.extensions.nvim_scrollbar.active then
    lvim.extensions[extension_name].setup = vim.tbl_extend("force", lvim.extensions[extension_name].setup, {
      build_position_cb = function(plist)
        require("scrollbar.handlers.search").handler.show(plist.start_pos)
      end,
    })

    vim.cmd [[
      augroup scrollbar_search_hide
        autocmd!
        autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
      augroup END
    ]]
  end

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
