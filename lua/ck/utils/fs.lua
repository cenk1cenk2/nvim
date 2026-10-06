local M = {}

---@module "plenary.path"

--- Returns the cwd for the project.
---@return string?
function M.get_cwd()
  local root = vim.uv.cwd()

  return root
end

--- Returns the git root of the buffer, which is the worktree it belongs to.
---@param bufnr? number
---@return string?
function M.get_git_root(bufnr)
  return vim.fs.root(bufnr or 0, { ".git" })
end

--- Returns the main worktree of the repository the buffer belongs to.
---@param bufnr? number
---@return string?
function M.get_git_main_worktree(bufnr)
  local root = M.get_git_root(bufnr)

  if not root then
    return nil
  end

  return (vim.system({ "git", "worktree", "list", "--porcelain" }, { cwd = root, text = true }):wait().stdout or ""):match("^worktree ([^\n]+)")
end

--- Changes the global cwd and announces it.
---@param path string
---@param label string
function M.set_cwd(path, label)
  require("ck.log"):info("Changing cwd to %s: %s", label, path)

  vim.api.nvim_set_current_dir(path)
end

--- Returns relative to user home directory cwd for the project.
---@return string
function M.get_relative_cwd()
  return M.get_relative_to_home(M.get_cwd())
end

--- Returns relative to user home directory cwd for the project.
---@param path string
---@return string
function M.get_relative_to_home(path)
  return vim.fn.fnamemodify(path, ":~")
end

--- Returns the buffer absolute file path.
---@param bufnr? number
---@return string
function M.get_buffer_filepath(bufnr)
  return require("plenary.path").new(vim.api.nvim_buf_get_name(bufnr or vim.api.nvim_get_current_buf())):absolute()
end

--- Returns the buffer absolute dir path.
---@param bufnr? number
---@return string
function M.get_buffer_dirpath(bufnr)
  return vim.fs.dirname(M.get_buffer_filepath(bufnr))
end

--- Returns the buffer relative file path in the project.
---@param bufnr? number
---@return string
function M.get_project_buffer_filepath(bufnr)
  return M.get_project_filepath(vim.api.nvim_buf_get_name(bufnr or vim.api.nvim_get_current_buf()))
end

--- Returns the buffer relative file path in the project.
---@param path? string
---@return string
function M.get_project_filepath(path)
  return require("plenary.path").new(path):make_relative()
end

--- Returns the buffer relative dir path in the project.
---@param bufnr? number
---@return string
function M.get_project_buffer_dirpath(bufnr)
  return M.get_project_dirpath(vim.api.nvim_buf_get_name(bufnr or vim.api.nvim_get_current_buf()))
end

--- Returns the buffer relative file path in the project.
---@param path? string
---@return string
function M.get_project_dirpath(path)
  return vim.fs.dirname(M.get_project_filepath(path))
end

--- Returns the buffer name.
---@param bufnr? number
---@return string
function M.get_buffer_name(bufnr)
  return vim.fs.basename(vim.api.nvim_buf_get_name(bufnr or vim.api.nvim_get_current_buf()))
end

--- Returns the buffer basename.
---@param bufnr? number
---@return string
function M.get_buffer_basename(bufnr)
  local name = M.get_buffer_name(bufnr)
  local match = string.match(name, "^(.*)%..*$")

  return match or name
end

--- Returns the buffer basename.
---@param bufnr? number
---@return string
function M.get_buffer_extension(bufnr)
  local match = string.match(M.get_buffer_name(bufnr), ".*%.(.*)$")

  return match
end

return M
