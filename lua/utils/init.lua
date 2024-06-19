local M = {}

local Log = require("lvim.core.log")

function M.treesitter_highlight(ft)
  return function(input)
    local parser = vim.treesitter.get_string_parser(input, ft)
    local tree = parser:parse()[1]
    local query = vim.treesitter.query.get(ft, "highlights")
    local highlights = {}

    for id, node, _ in query:iter_captures(tree:root(), input) do
      local _, cstart, _, cend = node:range()
      table.insert(highlights, { cstart, cend, "@" .. query.captures[id] })
    end

    return highlights
  end
end

function M.reload_file()
  local ok = pcall(function()
    vim.schedule(function()
      vim.cmd("e")
    end)
  end)

  if not ok then
    Log:warn(("Can not reload file since it is unsaved: %s"):format(vim.fn.expand("%")))
  end
end

function M.get_visual_selection()
  -- this will exit visual mode
  -- use 'gv' to reselect the text
  local _, csrow, cscol, cerow, cecol
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    -- if we are in visual mode use the live position
    _, csrow, cscol, _ = unpack(vim.fn.getpos("."))
    _, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
    if mode == "V" then
      -- visual line doesn't provide columns
      cscol, cecol = 0, 999
    end
    -- exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  else
    -- otherwise, use the last known visual position
    _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  end
  -- swap vars if needed
  if cerow < csrow then
    csrow, cerow = cerow, csrow
  end
  if cecol < cscol then
    cscol, cecol = cecol, cscol
  end
  local lines = vim.fn.getline(csrow, cerow)
  -- local n = cerow-csrow+1
  local n = #lines
  if n <= 0 then
    return ""
  end
  lines[n] = string.sub(lines[n], 1, cecol)
  lines[1] = string.sub(lines[1], cscol)

  return table.concat(lines, "\n")
end

function M.get_project_buffer_filepath(bufnr)
  bufnr = bufnr or 0

  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:~:.")
end

function M.get_project_buffer_dirpath(bufnr)
  bufnr = bufnr or 0

  return vim.fn.fnamemodify(vim.fn.expand("%:h:~:."), ":p:~:.")
end

function M.set_view_buffer()
  local bufnr = 0
  local winid = vim.api.nvim_get_current_win()

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].matchpairs = ""
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].synmaxcol = 0
  vim.wo[winid][bufnr].colorcolumn = ""
  vim.wo[winid][bufnr].cursorcolumn = false
  vim.wo[winid][bufnr].cursorline = false
  vim.wo[winid][bufnr].foldcolumn = "0"
  vim.wo[winid][bufnr].list = false
  vim.wo[winid][bufnr].number = false
  vim.wo[winid][bufnr].relativenumber = false
  vim.wo[winid][bufnr].signcolumn = "no"
  vim.wo[winid][bufnr].spell = false
end

return M
