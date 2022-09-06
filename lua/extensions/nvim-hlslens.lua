-- https://github.com/kevinhwang91/nvim-hlslens
local M = {}

local extension_name = "nvim_hlslens"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "kevinhwang91/nvim-hlslens",
        config = function()
          require("utils.setup").packer_config "nvim_hlslens"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        scrollbar_handlers_search = require "scrollbar.handlers.search",
      }
    end,
    setup = function(config)
      return {
        build_position_cb = function(plist)
          config.inject.scrollbar_handlers_search.handler.show(plist.start_pos)
        end,
      }
    end,
    on_setup = function(config)
      require("hlslens").setup(config.setup)
    end,
    on_done = function()
      vim.cmd [[
      augroup scrollbar_search_hide
        autocmd!
        autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
      augroup END
      ]]
    end,
  })
end

return M
