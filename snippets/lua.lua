local s = require("ck.utils.snippets")

return {
  s.postfix(".inspect", {
    s.f(function(_, parent)
      return "vim.notify(vim.inspect(" .. parent.snippet.env.POSTFIX_MATCH .. "))"
    end, {}),
  }),
}
