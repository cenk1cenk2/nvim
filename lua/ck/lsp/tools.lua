local M = {}

local log = require("ck.log")

---@class LspToolMethods
---@field FORMATTER string
---@field LINTER string
M.METHODS = {
  FORMATTER = "formatters",
  LINTER = "linters",
}

--- Reads the registered tools for a given method.
---@param method LspToolMethods
---@return any
function M.read(method)
  return nvim.lsp.tools.by_ft[method]
end

--- Write a configuration for given language.
---@param method LspToolMethods
---@param config any
---@param filetypes string[]
function M.configure(method, config, filetypes)
  for _, ft in pairs(filetypes) do
    if nvim.lsp.tools.by_ft[method][ft] == nil then
      nvim.lsp.tools.by_ft[method][ft] = {}
    end

    vim.tbl_extend("force", nvim.lsp.tools.by_ft[method][ft], config)
  end
end

--- Registers a tool for a given method.
---@param method LspToolMethods
---@param configs any
---@param filetypes string[]
function M.register(method, configs, filetypes)
  if type(configs) == "string" then
    configs = { configs }
  end

  for _, ft in pairs(filetypes) do
    if nvim.lsp.tools.by_ft[method][ft] == nil then
      nvim.lsp.tools.by_ft[method][ft] = {}
    end

    vim.list_extend(nvim.lsp.tools.by_ft[method][ft], configs)
  end

  log:debug(
    "Registered the following method %s for %s: %s",
    method,
    vim.tbl_map(function(config)
      if type(config) == "string" then
        return config
      end

      return config.name
    end, configs),
    table.concat(filetypes, ", ")
  )
end

---@param method LspToolMethods
---@param bufnr? number
---@return table
function M.list_registered(method, bufnr)
  bufnr = bufnr or 0

  local ft = vim.bo[bufnr].ft
  local tools = {}

  if nvim.lsp.tools.by_ft[method]["*"] then
    vim.list_extend(tools, nvim.lsp.tools.by_ft[method]["*"])
  end

  if nvim.lsp.tools.by_ft[method][ft] ~= nil then
    vim.list_extend(tools, nvim.lsp.tools.by_ft[method][ft])
  elseif nvim.lsp.tools.by_ft[method]["_"] ~= nil then
    vim.list_extend(tools, nvim.lsp.tools.by_ft[method]["_"])
  end

  return tools
end

return M
