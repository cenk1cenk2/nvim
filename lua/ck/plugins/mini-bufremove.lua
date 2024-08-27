-- https://github.com/echasnovski/mini.bufremove
local log = require("ck.log")

local M = {}

M.name = "echasnovski/mini.bufremove"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "echasnovski/mini.bufremove",
      }
    end,
    configure = function()
      nvim.fn.close_buffer = M.close_buffer
    end,
    commands = {
      {
        "BufferClose",
        function()
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

---@param bufnr? number defaults to the current buffer
---@param force? boolean defaults to false
function M.close_buffer(bufnr, force)
  -- https://github.com/echasnovski/mini.bufremove/blob/main/lua/mini/bufremove.lua
  if bufnr == 0 or bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if not force and is_loaded("bufferline") and require("bufferline.groups")._is_pinned({ id = bufnr }) then
    log:warn("Buffer is pinned!")

    return
  end

  require("mini.bufremove").wipeout(bufnr, force)
end

return M
