local s = require("ck.utils.snippets")

return {
  s.postfix({
    trig = ".viminspect",
    desc = "Vim notify and inspect the given object.",
  }, {
    s.f(function(_, parent)
      return "vim.notify(vim.inspect(" .. parent.snippet.env.POSTFIX_MATCH .. "))"
    end, {}),
  }),
  s.postfix({
    trig = ".fmt",
    desc = "Format a string.",
  }, {
    s.f(function(_, parent)
      return "(" .. parent.snippet.env.POSTFIX_MATCH .. "):format()"
    end, {}),
  }),
  -- s.treesitter_postfix({
  --   trig = ".fmt",
  --   desc = "Format the given string.",
  --   matchTSNode = {
  --     query = s.postfix_builtin.tsnode_matcher.find_topmost_types({
  --       "@string",
  --     }),
  --     query_lang = "lua",
  --   },
  -- }, {
  --   s.f(function(_, parent)
  --     return "(" .. parent.snippet.env.LS_TSMATCH .. "):format({})"
  --   end, {}),
  -- }),
}
