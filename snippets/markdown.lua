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
      trig = "f",
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
      trig = "o",
      name = "obsidian labels",
      desc = { "Adds obsidian labels seperator." },
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
      trig = "oa",
      name = "obsidian label aliases.",
    },
    s.fmt(
      [[
      aliases:
        - {}
      ]],
      {
        s.i(1, {
          require("textcase").api.to_title_case(string.gsub(vim.fn.expand("%:t"), "%.md$", "")),
        }),
      }
    )
  ),
  s.s(
    {
      trig = "ot",
      name = "obsidian label tags.",
    },
    s.fmt(
      [[
      tags:
        - {}
      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "ot",
      name = "obsidian label tags.",
    },
    s.fmt(
      [[
      tags:
        - {}
      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "ot",
      name = "obsidian label bookmarks.",
    },
    s.fmt(
      [[
      bookmarks:
        - {}
      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "oc",
      name = "obsidian label contacts.",
    },
    s.fmt(
      [[
      contacts:
        - {}
      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "tl",
      name = "task list item",
    },
    s.fmt(
      [[
      - [ ] {}
      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "ltl",
      name = "convert list item to task list item",
    },
    s.fmt(
      [[
      [ ] {}
      ]],
      {
        s.i(1),
      }
    )
  ),
}
