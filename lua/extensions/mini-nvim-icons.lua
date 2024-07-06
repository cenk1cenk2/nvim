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
  })
end

return M
