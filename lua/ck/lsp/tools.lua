local M = {}

local log = require("ck.log")

---@class LspToolMethods
---@field FORMATTER string
---@field LINTER string
M.METHODS = {
  FORMATTER = "formatters",
  LINTER = "linters",
}

function M.read_tools(method)
  return nvim.lsp.tools.by_ft[method]
end

function M.register_tools(method, configs, filetypes)
  if type(configs) == "string" then
    configs = { configs }
  end

  for _, ft in pairs(filetypes) do
    if nvim.lsp.tools.by_ft[method][ft] == nil then
      nvim.lsp.tools.by_ft[method][ft] = {}
    end

    vim.list_extend(nvim.lsp.tools.by_ft[method][ft], configs)
  end

  log:debug(("Registered the following method %s for %s: %s"):format(
    method,
    vim.inspect(vim.tbl_map(function(config)
      if type(config) == "string" then
        return config
      end

      return config.name
    end, configs)),
    table.concat(filetypes, ", ")
  ))
end

return M
