local s = require("utils.snippets")

return {
  s.s(
    "defaults",
    s.fmt(
      [[
      root = true

      [*]
      indent_style = space
      indent_size = 2
      end_of_line = lf
      insert_final_newline = true
      charset = utf-8
      quoute_type = double
      ]],
      {}
    )
  ),
}
