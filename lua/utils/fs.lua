local M = {}

function M.get_cwd()
  return vim.uv.cwd()
end

function M.get_relative_cwd()
  return vim.fn.fnamemodify(M.get_cwd(), ":~")
end

function M.get_buffer_filepath(bufnr)
  return require("plenary.path").new(vim.api.nvim_buf_get_name(bufnr or 0)):absolute()
end

function M.get_buffer_dirpath(bufnr)
  return vim.fs.dirname(M.get_buffer_filepath(bufnr))
end

function M.get_project_buffer_filepath(bufnr)
  return require("plenary.path").new(vim.api.nvim_buf_get_name(bufnr or 0)):make_relative()
end

function M.get_project_buffer_dirpath(bufnr)
  return vim.fs.dirname(M.get_project_buffer_filepath(bufnr))
end

return M
