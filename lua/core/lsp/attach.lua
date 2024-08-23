local M = {}

local nvim_lsp_utils = require("core.lsp.utils")

local skipped_filetypes = nvim.lsp.automatic_configuration.skipped_filetypes
local skipped_servers = nvim.lsp.automatic_configuration.skipped_servers
local ensure_installed_servers = nvim.lsp.installer.setup.ensure_installed

---Generates an ftplugin file based on the server_name in the selected directory
---@param server_name string name of a valid language server, e.g. pyright, gopls, tsserver, etc.
---@return boolean
function M.should_configure(server_name)
  if vim.tbl_contains(skipped_servers, server_name) and not vim.tbl_contains(ensure_installed_servers, server_name) then
    return false
  end

  -- get the supported filetypes and remove any ignored ones
  local filetypes = vim.tbl_filter(function(ft)
    return not vim.tbl_contains(skipped_filetypes, ft)
  end, nvim_lsp_utils.get_supported_filetypes(server_name) or {})

  if not filetypes or #filetypes == 0 then
    return false
  end

  return true
end

return M
