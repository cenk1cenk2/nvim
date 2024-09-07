-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local ls = require("luasnip")

local M = {
  f = ls.function_node,
  s = ls.s,
  i = ls.insert_node,
  t = ls.text_node,
  d = ls.dynamic_node,
  c = ls.choice_node,
  sn = ls.sn,
  postfix = require("luasnip.extras.postfix").postfix,
  fmt = require("luasnip.extras.fmt").fmt,
}

function M.same(index)
  return M.f(function(args)
    return args[1]
  end, { index })
end

return M
