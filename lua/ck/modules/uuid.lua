local M = {}

local log = require("ck.log")

function M.generate_v4()
  local handle = io.popen("uuidgen")
  if not handle then
    log:error("Failed to generate UUID: uuidgen not found")

    return nil
  end

  local uuid = handle:read("*a"):gsub("%s+", ""):lower()
  handle:close()

  return uuid
end

function M.copy()
  local uuid = M.generate_v4()
  if not uuid then
    return
  end

  vim.fn.setreg(vim.v.register or nvim.system_register, uuid)
  log:info(("Copied generated uuid to clipboard: %s"):format(uuid))
end

function M.insert()
  local uuid = M.generate_v4()
  if not uuid then
    return
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
  local new_line = line:sub(1, col) .. uuid .. line:sub(col + 1)
  vim.api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
  vim.api.nvim_win_set_cursor(0, { row, col + #uuid })
end

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "u" }),
          function()
            M.copy()
          end,
          desc = "generate uuid",
        },
        {
          fn.wk_keystroke({ categories.RUN, "U" }),
          function()
            M.insert()
          end,
          desc = "insert uuid",
        },
      }
    end,
  })
end

return M
