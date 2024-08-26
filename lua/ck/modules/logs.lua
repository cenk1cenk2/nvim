local M = {}

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      return {}
    end,
  })
end

return M
