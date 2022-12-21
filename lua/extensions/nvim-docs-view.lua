-- https://github.com/amrbashir/nvim-docs-view
local M = {}

local extension_name = "nvim_docs_view"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "amrbashir/nvim-docs-view",
        cmd = { "DocsViewToggle" },
        enabled = config.active,
      }
    end,
    setup = {
      position = "bottom",
      width = 75,
    },
    on_setup = function(config)
      require("docs-view").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.LSP] = { ["v"] = { ":DocsViewToggle<CR>", "toggle documentation" } },
      }
    end,
  })
end

return M
