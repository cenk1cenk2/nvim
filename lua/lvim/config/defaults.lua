lvim = {
  leader = " ",
  localleader = ",",
  colorscheme = "onedarker",

  ui = {
    icons = require("lvim.config.icons"),
    colors = require("onedarker.colors"),
    border = "single",
    transparent_window = false,
  },

  selection_chars = "asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM",
  system_register = "+",

  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "info",
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

  disabled_buffer_types = {
    "terminal",
    "prompt",
    "quickfix",
  },

  keys = {},
  extensions = {},
  plugins = {},
  autocommands = {},
  fn = {},
  wk = {},
}

return lvim
