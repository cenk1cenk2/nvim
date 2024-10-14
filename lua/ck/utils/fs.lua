local M = {}

---@module "plenary.path"

--- Returns the cwd for the project.
---@return string?
function M.get_cwd()
  local root = vim.uv.cwd()

  return root
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
  return require("plenary.path").new(vim.api.nvim_buf_get_name(bufnr or 0)):absolute()
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
  return M.get_project_filepath(vim.api.nvim_buf_get_name(bufnr or 0))
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
  return M.get_project_dirpath(vim.api.nvim_buf_get_name(bufnr or 0))
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
  return vim.fs.basename(vim.api.nvim_buf_get_name(bufnr or 0))
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
