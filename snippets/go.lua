local s = require("ck.utils.snippets")

local ts_lang = "go"
local ts_query = {
  return_result = "LuaSnip_Result",
}

vim.treesitter.query.set(
  ts_lang,
  ts_query.return_result,
  [[ [
    (method_declaration result: (_) @id)
    (function_declaration result: (_) @id)
    (func_literal result: (_) @id)
  ] ]]
)

local transform = function(text, info)
  if text == "int" then
    return s.t("0")
  elseif text == "error" then
    if info then
      info.index = info.index + 1

      return s.c(info.index, {
        s.t(info.err_name),
      })
    else
      return s.t("err")
    end
  elseif text == "bool" then
    return s.t("false")
  elseif text == "string" then
    return s.t('""')
  elseif string.find(text, "*", 1, true) then
    return s.t("nil")
  end

  return s.t(text)
end

local handlers = {
  ["parameter_list"] = function(node, info)
    local result = {}

    local count = node:named_child_count()
    for idx = 0, count - 1 do
      table.insert(result, transform(vim.treesitter.get_node_text(node:named_child(idx), 0), info))
      if idx ~= count - 1 then
        table.insert(result, s.t({ ", " }))
      end
    end

    return result
  end,

  ["type_identifier"] = function(node, info)
    local text = vim.treesitter.get_node_text(node, 0)
    return { transform(text, info) }
  end,
}

local function go_result_type(info)
  -- Get current node at cursor using core Neovim treesitter API
  local node = vim.treesitter.get_node()
  if not node then
    return { s.t("nil") }
  end

  -- Walk up the tree to find the enclosing function/method declaration
  local function_node
  local current = node
  while current do
    local node_type = current:type()
    if node_type == "function_declaration" or node_type == "method_declaration" or node_type == "func_literal" then
      function_node = current
      break
    end
    current = current:parent()
  end

  if not function_node then
    return { s.t("nil") }
  end

  local query = vim.treesitter.query.get(ts_lang, ts_query.return_result)
  if not query then
    return { s.t("nil") }
  end

  for _, captured_node in query:iter_captures(function_node, 0) do
    if handlers[captured_node:type()] then
      return handlers[captured_node:type()](captured_node, info)
    end
  end

  return { s.t("nil") }
end

local go_return = function(args)
  if not args or #args < 1 then
    args = {}
    args[1] = { "nil" }
  end

  return s.sn(
    nil,
    go_result_type({
      index = 0,
      err_name = args[1][1],
    })
  )
end

return {
  s.s(
    {
      trig = "implements",
      desc = "Implement an interface into a struct.",
    },
    s.fmt("var _ <> = (*<>)(nil)", {
      s.i(1, { "interface" }),
      s.i(2, { "struct" }),
    }, { delimiters = "<>" })
  ),
  s.s(
    {
      trig = "ifnok",
      name = "if not ok",
      desc = "if not ok, return.",
    },
    s.fmt(
      [[
      if !<> {
        return <>
      }
      ]],
      {
        s.i(1, { "ok" }),
        s.d(2, go_return, { 1 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      trig = "ifnoki",
      name = "if not ok inline",
      desc = "if not ok with inline variable, return.",
    },
    s.fmt(
      [[
      if <>, <> := <>(<>); !<> {
        return <>
      }
      ]],
      {
        s.i(1, { "val" }),
        s.i(2, { "ok" }),
        s.i(3, { "fn" }),
        s.i(4),
        s.same(2),
        s.d(5, go_return, { 1 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      trig = "iferr",
      name = "if err",
      desc = "if err, return",
    },
    s.fmt(
      [[
      if <> != nil {
        return <>
      }
      ]],
      {
        s.i(1, { "err" }),
        s.d(2, go_return, { 1 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      trig = "iferri",
      name = "if err inline",
      desc = "if err with inline variable, return",
    },
    s.fmt(
      [[
      if <> := <>(<>); <> != nil {
        return <>
      }
      ]],
      {
        s.i(1, { "err" }),
        s.i(2, { "fn" }),
        s.i(3),
        s.same(1),
        s.d(4, go_return, { 1 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      trig = "iferrc",
      name = "if err with call",
      desc = "if err with calling function, return",
    },
    s.fmt(
      [[
      <>, <> := <>(<>)

      if <> != nil {
        return <>
      }
      ]],
      {
        s.i(1, { "val" }),
        s.i(2, { "err" }),
        s.i(3, { "fn" }),
        s.i(4),
        s.same(2),
        s.d(5, go_return, { 2 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    {
      trig = "ginkgo",
      name = "import ginkgo",
      desc = "imports ginkgo and gomega for testing.",
    },
    s.fmt(
      [[
      . "github.com/onsi/ginkgo/v2"
      . "github.com/onsi/gomega"
      ]],
      {}
    )
  ),
  s.s(
    {
      trig = "ret",
      name = "return with types",
      desc = "return with types",
    },
    s.fmt(
      [[
        return <>
      ]],
      {
        s.d(1, go_return),
      },
      { delimiters = "<>" }
    )
  ),
}
