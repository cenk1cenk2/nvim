local s = require("utils.snippets")

local ts_locals = require("nvim-treesitter.locals")
local ts_utils = require("nvim-treesitter.ts_utils")
local get_node_text = vim.treesitter.get_node_text

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
      table.insert(result, transform(get_node_text(node:named_child(idx), 0), info))
      if idx ~= count - 1 then
        table.insert(result, s.t({ ", " }))
      end
    end

    return result
  end,

  ["type_identifier"] = function(node, info)
    local text = get_node_text(node, 0)
    return { transform(text, info) }
  end,
}

local function go_result_type(info)
  local cursor_node = ts_utils.get_node_at_cursor()
  local scope = ts_locals.get_scope_tree(cursor_node, 0)

  local function_node
  for _, v in ipairs(scope) do
    if v:type() == "function_declaration" or v:type() == "method_declaration" or v:type() == "func_literal" then
      function_node = v
      break
    end
  end

  local query = vim.treesitter.query.get(ts_lang, ts_query.return_result)
  for _, node in query:iter_captures(function_node, 0) do
    if handlers[node:type()] then
      return handlers[node:type()](node, info)
    end
  end

  return { s.t("nil") }
end

local go_ret_vals = function(args)
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
    "implements",
    s.fmt("var _ <> = (*<>)(nil)", {
      s.i(1, { "interface" }),
      s.i(2, { "struct" }),
    }, { delimiters = "<>" })
  ),
  s.s(
    "iferr",
    s.fmt(
      [[
      if <> != nil {
        return <>
      }
      ]],
      {
        s.i(1, { "err" }),
        s.d(2, go_ret_vals, { 1 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    "iferri",
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
        s.d(4, go_ret_vals, { 1 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    "iferrc",
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
        s.d(5, go_ret_vals, { 2 }),
      },
      { delimiters = "<>" }
    )
  ),
  s.s(
    "ginkgo",
    s.fmt(
      [[
      . "github.com/onsi/ginkgo/v2"
      . "github.com/onsi/gomega"
      ]],
      {}
    )
  ),
}
