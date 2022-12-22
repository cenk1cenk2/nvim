-- mrshmllow/document-color.nvim
local M = {}

local extension_name = "document_color_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "mrshmllow/document-color.nvim",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
      }
    end,
    setup = {
      mode = "background", -- "background" | "foreground" | "single"
    },
    on_setup = function(config)
      require("document-color").setup(config.setup)
    end,
  })
end

return M
