lvim = {
  leader = "space",
  colorscheme = "onedarker",
  format_on_save = {
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 7500,
    ---@usage filter func to select client
    filter = require("lvim.lsp.utils").format_filter,
  },

  ui = {
    icons = require("lvim.icons"),
    colors = require("onedarker.colors"),
    border = "single",
    transparent_window = false,
  },

  selection_chars = "asdfgzxcqwervbrt",
  system_register = "+",

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
  },

  store = {
    set_store = function(key, value)
      lvim.store[key] = value
    end,
    get_store = function(key)
      return lvim.store[key]
    end,
  },

  disabled_filetypes = {
    "terminal",
    "checkhealth",
    "packer",
    "lazy",
    "lspinfo",
    "prompt",
    "notify",
    "qf",
    "lsp_floating_window",
    "diff",
    "help",
    "vimdoc",
    "prompt",
  },

  keys = {},
  extensions = {},
  plugins = {},
  autocommands = {},
  fn = {},
  wk = {
    mappings = {},
    vmappings = {},
  },
}

return lvim
