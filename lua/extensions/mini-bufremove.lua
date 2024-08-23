-- https://github.com/echasnovski/mini.bufremove
local log = require("lvim.log")

local M = {}

M.name = "echasnovski/mini.bufremove"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "echasnovski/mini.bufremove",
      }
    end,
    configure = function(_, fn)
      fn.add_global_function("close_buffer", M.close_buffer)
    end,
    commands = {
      {
        name = "BufferClose",
        fn = function()
          M.close_buffer()
        end,
      },
    },
    keymaps = function()
      return {
        {
          "<C-q>",
          function()
            M.close_buffer()
          end,
          desc = "close current buffer",
          mode = { "n" },
        },
      }
    end,
  })
end

-- Common kill function for bdelete and bwipeout
-- credits: based on bbye and nvim-bufdel
---@param bufnr? number defaults to the current buffer
---@param force? boolean defaults to false
function M.close_buffer(bufnr, force)
  -- https://github.com/echasnovski/mini.bufremove/blob/main/lua/mini/bufremove.lua
  if bufnr == 0 or bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if not force and is_package_loaded("bufferline") and require("bufferline.groups")._is_pinned({ id = bufnr }) then
    log:warn("Buffer is pinned!")

    return
  end

  require("mini.bufremove").wipeout(bufnr, force)
end

return M
