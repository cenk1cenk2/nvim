local M = {}

local function is_ft(b, ft)
  return vim.bo[b].filetype == ft
end

local function diagnostics_indicator(_, _, diagnostics)
  local result = {}
  local symbols = { error = "", warning = "", info = "" }
  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. " " .. count)
    end
  end
  result = table.concat(result, " ")
  return #result > 0 and result or ""
end

local function custom_filter(buf, buf_nums)
  local logs = vim.tbl_filter(function(b)
    return is_ft(b, "log")
  end, buf_nums)
  if vim.tbl_isempty(logs) then
    return true
  end
  local tab_num = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr "$"
  local is_log = is_ft(buf, "log")
  if last_tab == 1 then
    return true
  end
  -- only show log buffers in secondary tabs
  return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
end

M.config = function()
  lvim.builtin.bufferline = {
    active = true,
    on_config_done = nil,
    keymap = {
      normal_mode = {
        ["<M-l>"] = ":BufferNext<CR>",
        ["<M-j>"] = ":BufferMoveNext<CR>",
        ["<M-h>"] = ":BufferPrevious<CR>",
        ["<M-k>"] = ":BufferMovePrevious<CR>",
      },
    },
  }
end

M.setup = function()
  require("lvim.keymappings").load(lvim.builtin.bufferline.keymap)

  if lvim.builtin.bufferline.on_config_done then
    lvim.builtin.bufferline.on_config_done()
  end
end

-- Common kill function for bdelete and bwipeout
-- credits: based on bbye and nvim-bufdel
---@param kill_command String defaults to "bd"
---@param bufnr Number defaults to the current buffer
---@param force Boolean defaults to false
function M.buf_kill(kill_command, bufnr, force)
  local bo = vim.bo
  local api = vim.api

  if bufnr == 0 or bufnr == nil then
    bufnr = api.nvim_get_current_buf()
  end

  kill_command = kill_command or "bd"

  -- If buffer is modified and force isn't true, print error and abort
  if not force and bo[bufnr].modified then
    return api.nvim_err_writeln(
      string.format("No write since last change for buffer %d (set force to true to override)", bufnr)
    )
  end

  -- Get list of windows IDs with the buffer to close
  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, api.nvim_list_wins())

  if #windows == 0 then
    return
  end

  if force then
    kill_command = kill_command .. "!"
  end

  -- Get list of active buffers
  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
  end, api.nvim_list_bufs())

  -- If there is only one buffer (which has to be the current one), vim will
  -- create a new buffer on :bd.
  -- For more than one buffer, pick the previous buffer (wrapping around if necessary)
  if #buffers > 1 then
    for i, v in ipairs(buffers) do
      if v == bufnr then
        local prev_buf_idx = i == 1 and (#buffers - 1) or (i - 1)
        local prev_buffer = buffers[prev_buf_idx]
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, prev_buffer)
        end
      end
    end
  end

  -- Check if buffer still exists, to ensure the target buffer wasn't killed
  -- due to options like bufhidden=wipe.
  if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
    vim.cmd(string.format("%s %d", kill_command, bufnr))
  end
end

return M
