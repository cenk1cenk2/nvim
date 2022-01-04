local M = {}

local function get_content_buf(bufnr)
  local content_table = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  return content_table
end

M.get_term_by_id = function(id)
  local terms = M.get_terms()

  return terms[id]
end

M.get_terms = function()
  local terms_table = require("toggleterm.terminal").get_all(true)
  local terms = {}
  for _, term in pairs(terms_table) do
    table.insert(terms, {
      bufnr = term.bufnr,
      id = term.id,
      terminal = term,
      content = get_content_buf(term.bufnr),
      name = term.name,
    })
  end
  return terms
end

M.get_term_id_by_bufnr = function(bufnr)
  local terms = M.get_terms()
  for _, v in pairs(terms) do
    if v.bufnr == bufnr then
      return v.id
    end
  end
  return nil
end

return M
