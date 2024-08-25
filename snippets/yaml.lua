local s = require("ck.utils.snippets")

return {
  s.s(
    {
      trig = "f",
      name = "frontmatter seperator",
      desc = { "Adds frontmatter seperator." },
    },
    s.fmt(
      [[
      ---

      ]],
      {}
    )
  ),
  s.s(
    {
      trig = "o",
      name = "double frontmatter seperator",
      desc = { "Adds double frontmatter seperator." },
    },
    s.fmt(
      [[
      ---
      {}
      ---

      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "schema",
      name = "Yaml Schema",
      desc = { "Adds a yaml-language-server schema to current buffer." },
    },
    s.fmt(
      [[
      # yaml-language-server: $schema={}
      ]],
      {
        s.i(1),
      }
    )
  ),
}
