return {
  leader = " ",
  localleader = ",",
  colorscheme = "onedarker",

  ui = {
    icons = require("core.config.icons"):load(),
    colors = require("onedarker.colors"),
    border = "single",
    transparent = false,
  },

  selection_chars = "asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM",
  system_register = "+",

  log = {
    ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
    level = "info",
    viewer = {
      ---@usage this will fallback on "less +F" if not found
      cmd = "lnav",
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

  extensions = {},

  fn = {},
  wk = {},
}
