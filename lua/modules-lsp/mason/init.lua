local M = {}
local Log = require "lvim.core.log"

function M.setup()
  local installers = {
    "markdown-toc",
    "rustywind",
    "codespell",
    "beautysh",
    "md-printer",
  }

  for _, r in ipairs(installers) do
    local ok, _ = pcall(require, "modules-lsp.mason." .. r)

    if not ok then
      Log:warn(("Mason server can not be setup: %s").format(r))
    end
  end
end

return M
