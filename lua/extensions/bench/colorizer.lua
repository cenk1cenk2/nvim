-- https://github.com/NvChad/nvim-colorizer.lua
local M = {}

local extension_name = "colorizer"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvchad/nvim-colorizer.lua",
        config = function()
          require("utils.setup").packer_config "colorizer"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      filetypes = { "markdown", "html", "css", "scss", "vue", "javascriptreact", "typescriptreact" },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- "Name" codes like Blue or blue
        RRGGBBAA = false, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "background", -- Set the display mode.
        virtualtext = "■",
      },
      -- all the sub-options of filetypes apply to buftypes
      buftypes = {},
    },
    on_setup = function(config)
      require("colorizer").setup(config.setup)
    end,
    wk = {
      ["a"] = {
        ["C"] = { ":ColorizerToggle<CR>", "toggle colorizer" },
      },
    },
  })
end

return M
