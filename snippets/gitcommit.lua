local s = require("ck.utils.snippets")

return {
  s.s(
    {
      trig = "sci",
      name = "skip-ci",
      desc = { "Skips the CI configuration in pipelines." },
    },
    s.fmt(
      [[
      [skip-ci]
      ]],
      {}
    )
  ),
}
