local M = {}

local log = require("ck.log")

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
    log:warn(("Can not reload file since it is unsaved: %s"):format(vim.fn.expand("%")))
  end
end

---@return string[]?
function M.get_visual_selection()
  -- from https://www.reddit.com/r/neovim/comments/1b1sv3a/function_to_get_visually_selected_text/
  local _, srow, scol = unpack(vim.fn.getpos("v"))
  local _, erow, ecol = unpack(vim.fn.getpos("."))

  -- visual line mode
  if vim.fn.mode() == "V" then
    if srow > erow then
      return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
    else
      return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
    end
  end

  -- regular visual mode
  if vim.fn.mode() == "v" then
    if srow < erow or (srow == erow and scol <= ecol) then
      return vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
    else
      return vim.api.nvim_buf_get_text(0, erow - 1, ecol - 1, srow - 1, scol, {})
    end
  end

  -- visual block mode
  if vim.fn.mode() == "\22" then
    local lines = {}
    if srow > erow then
      srow, erow = erow, srow
    end
    if scol > ecol then
      scol, ecol = ecol, scol
    end
    for i = srow, erow do
      table.insert(lines, vim.api.nvim_buf_get_text(0, i - 1, math.min(scol - 1, ecol), i - 1, math.max(scol - 1, ecol), {})[1])
    end
    return lines
  end
end

---@param opts { prompt: string, choices: { label: string, callback?: fun(): nil }[] }
function M.ui_confirm(opts)
  vim.schedule(function()
    local choice = vim.fn.confirm(
      opts.prompt,
      table.concat(
        vim.tbl_map(function(choice)
          return "&" .. choice.label
        end, opts.choices),
        "\n"
      )
    )

    if choice == 0 then
      return
    end

    local cb = opts.choices[choice].callback

    if type(cb) == "function" then
      cb()
    end
  end)
end

function M.bell()
  local tty = vim.uv.new_tty(2, false)
  if tty then
    tty:write("\007")
    tty:close()
  end
end

return M
