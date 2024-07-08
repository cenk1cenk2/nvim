--
local M = {}

local extension_name = "template"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "echasnovski/mini.icons",
        event = "UIEnter",
      }
    end,
    setup = function()
      return {
        -- Icon style: 'glyph' or 'ascii'
        style = "glyph",

        -- Customize per category. See `:h MiniIcons.config` for details.
        default = {},
        directory = {},
        extension = {},
        file = {},
        filetype = {},
        lsp = {},
        os = {},
      }
    end,
    on_setup = function(config)
      require("mini.icons").setup(config.setup)
      require("mini.icons").mock_nvim_web_devicons()
    end,
    on_done = function()
      local icons = require("mini.icons")

      lvim.ui.icons = vim.tbl_deep_extend("force", lvim.ui.icons, {
        kind = {
          Array = icons.get("lsp", "array"),
          Boolean = icons.get("lsp", "boolean"),
          Class = icons.get("lsp", "class"),
          Color = icons.get("lsp", "color"),
          Event = icons.get("lsp", "event"),
          File = icons.get("lsp", "file"),
          Folder = icons.get("lsp", "folder"),
          Function = icons.get("lsp", "function"),
          Key = icons.get("lsp", "key"),
          Method = icons.get("lsp", "method"),
          Module = icons.get("lsp", "module"),
          Namespace = icons.get("lsp", "namespace"),
          Null = icons.get("lsp", "null"),
          Number = icons.get("lsp", "number"),
          Object = icons.get("lsp", "object"),
          Operator = icons.get("lsp", "operator"),
          Package = icons.get("lsp", "package"),
          Snippet = icons.get("lsp", "snippet"),
          String = icons.get("lsp", "string"),
          Text = icons.get("lsp", "text"),
          TypeParameter = icons.get("lsp", "typeparameter"),
          Unit = icons.get("lsp", "unit"),
          Constructor = icons.get("lsp", "constructor"),
          Field = icons.get("lsp", "field"),
          Variable = icons.get("lsp", "variable"),
          Interface = icons.get("lsp", "interface"),
          Value = icons.get("lsp", "value"),
          Enum = icons.get("lsp", "enum"),
          Keyword = icons.get("lsp", "keyword"),
          Reference = icons.get("lsp", "reference"),
          EnumMember = icons.get("lsp", "enummember"),
          Constant = icons.get("lsp", "constant"),
          Property = icons.get("lsp", "property"),
          Struct = icons.get("lsp", "struct"),
          Copilot = "󰚩",
        },
      })
    end,
  })
end

return M
