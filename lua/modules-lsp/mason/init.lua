local M = {}
local Log = require "lvim.core.log"

local installers = {
  "modules-lsp.mason.markdown-toc",
  "modules-lsp.mason.rustywind",
  "modules-lsp.mason.jsonlint",
  "modules-lsp.mason.codespell",
  "modules-lsp.mason.checkmake",
}

function M.setup()
  for _, r in ipairs(installers) do
    local ok, _ = pcall(require, r)

    if not ok then
      Log:warn(("Mason server can not be setup: %s").format(r))
    end
  end
end

return M
