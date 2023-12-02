-- https://github.com/kevinhwang91/nvim-hlslens
local M = {}

local extension_name = "nvim_hlslens"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "kevinhwang91/nvim-hlslens",
        event = "BufReadPost",
      }
    end,
    setup = function()
      local scrollbar_handlers_search = require("scrollbar.handlers.search")

      return {
        build_position_cb = function(plist)
          scrollbar_handlers_search.handler.show(plist.start_pos)
        end,
      }
    end,
    on_setup = function(config)
      require("hlslens").setup(config.setup)
    end,
    on_done = function(_, fn)
      if fn.is_extension_enabled("nvim_scrollbar") then
        vim.cmd([[
        augroup scrollbar_search_hide
          autocmd!
          autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
        augroup END
      ]])
      end
    end,
  })
end

return M
