local s = require("ck.utils.snippets")

return {
  s.s(
    {
      trig = "ddq",
      name = "defaults [double-quote]",
      desc = { "Defaults with double quoutes." },
    },
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
