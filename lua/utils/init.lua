local M = {}

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

return M
