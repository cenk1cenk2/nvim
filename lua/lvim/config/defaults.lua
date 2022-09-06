lvim = {
  leader = "space",
  colorscheme = "onedarker",
  transparent_window = false,
  format_on_save = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 5000,
    ---@usage filter func to select client
    filter = require("lvim.lsp.utils").format_filter,
  },
  keys = {},

  use_icons = true,

  builtin = {},
  extensions = {},

  plugins = {},

  autocommands = {},
  lang = {},
  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "debug",
    viewer = {
      ---@usage this will fallback on "less +F" if not found
      cmd = "lnav",
      layout_config = {
        ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
        direction = "float",
        open_mapping = "",
        size = 40,
        float_opts = {},
      },
    },
    override_notify = true,
  },

  lsp_wrapper = {},

  store = {
    set_store = function(key, value)
      lvim.store[key] = value
    end,
    get_store = function(key)
      return lvim.store[key]
    end,
  },
}

return lvim
