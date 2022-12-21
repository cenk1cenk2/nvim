-- mrshmllow/document-color.nvim
local M = {}

local extension_name = "document_color_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "mrshmllow/document-color.nvim",
        config = function()
          require("utils.setup").plugin_init "document_color_nvim"
        end,
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
        enabled = config.active,
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
