-- https://github.com/simrat39/symbols-outline.nvim
-- TODO: remove this whenever lsp-saga is following current context
local M = {}

local extension_name = "symbols_outline"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "simrat39/symbols-outline.nvim",
        config = function()
          require("utils.setup").packer_config "symbols_outline"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      highlight_hovered_item = true,
      show_guides = true,
      auto_preview = true,
      preview_bg_highlight = "NormalFloat",
      position = "right",
      width = 50,
      keymaps = {
        close = "q",
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<C-Space>",
        rename_symbol = "r",
        code_actions = "a",
      },
      lsp_blacklist = {},
    },
    on_setup = function(config)
      require("symbols-outline").setup(config.setup)
    end,
    wk = {
      ["l"] = {
        ["o"] = { ":SymbolsOutline<CR>", "file outline" },
      },
    },
  })
end

return M
