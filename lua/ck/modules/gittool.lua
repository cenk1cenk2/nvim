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

local function current_data()
  return require("ck.modules.flatten").get_data("gittool") or {}
end

function M.flatten_guest_data()
  if vim.env.DIFFVIEW_GITTOOL_MODE == nil then
    return nil
  end

  return {
    mode = vim.env.DIFFVIEW_GITTOOL_MODE,
    left = vim.env.DIFFVIEW_LEFT,
    right = vim.env.DIFFVIEW_RIGHT,
    output = vim.env.DIFFVIEW_OUTPUT,
    merged = vim.env.DIFFVIEW_MERGED,
    base = vim.env.DIFFVIEW_BASE,
    local_path = vim.env.DIFFVIEW_LOCAL,
    remote = vim.env.DIFFVIEW_REMOTE,
  }
end

function M.diff(data)
  data = data or current_data()

  local left = normalize(data.left) or env("DIFFVIEW_LEFT") or argv(0)
  local right = normalize(data.right) or env("DIFFVIEW_RIGHT") or argv(1)
  local output = normalize(data.output) or env("DIFFVIEW_OUTPUT") or argv(2)

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

function M.merge(data)
  data = data or current_data()

  local output = normalize(data.merged) or env("DIFFVIEW_MERGED") or argv(0)
  local base = normalize(data.base) or env("DIFFVIEW_BASE") or argv(1)
  local left = normalize(data.local_path) or env("DIFFVIEW_LOCAL") or argv(2)
  local right = normalize(data.remote) or env("DIFFVIEW_REMOTE") or argv(3)

  if not right then
    left = normalize(data.local_path) or env("DIFFVIEW_LOCAL") or argv(1)
    right = normalize(data.remote) or env("DIFFVIEW_REMOTE") or argv(2)
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

function M.open_from_gittool()
  local data = current_data()
  local blocker = vim.api.nvim_get_current_buf()

  if data.mode == "merge" or vim.env.DIFFVIEW_GITTOOL_MODE == "merge" then
    M.merge(data)
  else
    M.diff(data)
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "DiffviewViewClosed",
    once = true,
    callback = function()
      require("ck.modules.flatten").clear_data("gittool")
      if vim.api.nvim_buf_is_valid(blocker) then
        vim.api.nvim_buf_delete(blocker, { force = true })
      end
    end,
  })
end

return M
