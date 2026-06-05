local M = {}

local function normalize(value)
  if value == nil or value == "" then
    return nil
  end

  return vim.fn.fnamemodify(value, ":p")
end

local function argv(index)
  return normalize(vim.fn.argv(index))
end

local function env(name)
  return normalize(vim.env[name])
end

local function exec(command, args)
  local escaped = {}
  for _, arg in ipairs(args) do
    escaped[#escaped + 1] = vim.fn.fnameescape(arg)
  end

  vim.cmd(command .. " " .. table.concat(escaped, " "))
end

function M.diff()
  local left = env("DIFFVIEW_LEFT") or argv(0)
  local right = env("DIFFVIEW_RIGHT") or argv(1)
  local output = env("DIFFVIEW_OUTPUT") or argv(2)

  if not left or not right then
    vim.notify("diffview git difftool requires left and right paths.", vim.log.levels.ERROR)

    return
  end

  if vim.fn.isdirectory(left) == 1 and vim.fn.isdirectory(right) == 1 then
    local args = { left, right }
    if output then
      args[#args + 1] = output
    end

    exec("DiffviewDiffDirs", args)

    return
  end

  exec("DiffviewDiffFiles", { left, right })
end

function M.merge()
  local output = env("DIFFVIEW_MERGED") or argv(0)
  local base = env("DIFFVIEW_BASE") or argv(1)
  local left = env("DIFFVIEW_LOCAL") or argv(2)
  local right = env("DIFFVIEW_REMOTE") or argv(3)

  if not right then
    left = argv(1)
    right = argv(2)
    base = nil
  end

  if not output or not left or not right then
    vim.notify("diffview git mergetool requires output, left, and right paths.", vim.log.levels.ERROR)

    return
  end

  if base and vim.fn.filereadable(base) == 1 then
    exec("DiffviewMergeFiles", { output, base, left, right })

    return
  end

  exec("DiffviewMergeFiles", { output, left, right })
end

return M
