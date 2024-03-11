-- https://github.com/echasnovski/mini.bufremove
local Log = require("lvim.core.log")

local M = {}

local extension_name = "echasnovski/mini.bufremove"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
    keymaps = {
      {
        { "n" },

        ["<C-q>"] = {
          function()
            M.close_buffer()
          end,
          { desc = "close current buffer" },
        },
      },
    },
    -- autocmds = {
    --   {
    --     { "BufLeave" },
    --     {
    --       pattern = "{}",
    --       callback = function(args)
    --         if vim.api.nvim_buf_get_name(args.buf) == "" and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
    --           -- vim.bo.buftype = "nofile"
    --           vim.bo.bufhidden = "unload"
    --         end
    --       end,
    --       group = "_empty_buffer",
    --     },
    --   },
    -- },
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

  if not force and package_is_loaded("bufferline") and require("bufferline.groups")._is_pinned({ id = bufnr }) then
    Log:warn("Buffer is pinned!")

    return
  end

  require("mini.bufremove").wipeout(bufnr, force)
end

return M
