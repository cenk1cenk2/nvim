local M = {}

local extension_name = "colorizer"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    ft = { "*" },
    setup = {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      rgb_fn = true, -- CSS rgb() and rgba() functions
      hsl_fn = true, -- CSS hsl() and hsla() functions
      css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
    },
  }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].ft, lvim.extensions[extension_name].setup)

  lvim.builtin.which_key.mappings["a"]["C"] = { ":ColorizerToggle<CR>", "colorizer toggle" }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
