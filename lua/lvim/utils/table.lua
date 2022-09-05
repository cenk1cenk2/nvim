local M = {}

--- Find the first entry for which the predicate returns true.
-- @param t The table
-- @param predicate The function called for each entry of t
-- @return The entry for which the predicate returned True or nil
function M.find_first(t, predicate)
  for _, entry in pairs(t) do
    if predicate(entry) then
      return entry
    end
  end
  return nil
end

function M.merge(a, b)
  local result = { unpack(a) }

  table.move(b, 1, #b, #result + 1, result)

  return result
end

return M
