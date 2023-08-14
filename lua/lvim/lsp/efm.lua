local M = {}

local Log = require("lvim.core.log")

M.METHOD = {
  FORMATTER = "FORMATTER",
  LINTER = "LINTER",
}

M.CLIENT_NAME = "efm"

function M.load(server)
  return require("modules.lsp.efm.config." .. server)
end

function M.list_registered(filetype, method)
  return vim.tbl_map(
    function(client)
      return client.name
    end,
    vim.tbl_filter(function(client)
      if method ~= nil and client.method and client.method ~= method then
        return false
      end

      return true
    end, lvim.lsp.efm.languages[filetype] or {})
  )
end

function M.register(configs, filetypes)
  for _, ft in pairs(filetypes) do
    if lvim.lsp.efm.languages[ft] == nil then
      lvim.lsp.efm.languages[ft] = {}
    end

    vim.list_extend(lvim.lsp.efm.languages[ft], configs)
  end

  Log:debug(("Registered the following sources for %s: %s"):format(
    vim.tbl_map(function(config)
      return config.name
    end, configs),
    table.concat(filetypes, ", ")
  ))
end

function M.setup()
  require("modules.lsp.efm").setup()

  require("lvim.lsp.manager").setup(M.CLIENT_NAME)
end

return M
