-- https://github.com/NvChad/nvim-colorizer.lua
local M = {}

M.name = "NvChad/nvim-colorizer.lua"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "NvChad/nvim-colorizer.lua",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
      }
    end,
    setup = function()
      return {
        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },
        user_default_options = {
          RGB = false, -- #RGB hex codes
          RRGGBB = false, -- #RRGGBB hex codes
          names = false, -- "Name" codes like Blue or blue
          RRGGBBAA = false, -- #RRGGBBAA hex codes
          AARRGGBB = false, -- 0xAARRGGBB hex codes
          rgb_fn = false, -- CSS rgb() and rgba() functions
          hsl_fn = false, -- CSS hsl() and hsla() functions
          css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Available modes for `mode`: foreground, background,  virtualtext
          mode = "background", -- Set the display mode.
          -- Available methods are false / true / "normal" / "lsp" / "both"
          -- True is same as normal
          tailwind = "lsp", -- Enable tailwind colors
          -- parsers can contain values used in |user_default_options|
          sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
          virtualtext = "■",
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = true,
        },
        -- all the sub-options of filetypes apply to buftypes
        buftypes = {},
      }
    end,
    on_setup = function(c)
      require("colorizer").setup(c)
    end,
  })
end

return M
