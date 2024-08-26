return {
  leader = " ",
  localleader = ",",
  colorscheme = "onedarker",

  ui = {
    icons = require("ck.config.icons"),
    colors = require("onedarker.colors"),
    border = "single",
    transparent = false,
  },

  selection_chars = "asdfghjklqwertyuiopzxcvbnmASDFGHJKLQWERTYUIOPZXCVBNM",
  system_register = "+",

  log = {
    level = "info",
    viewer = {
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

  ---@type table<string, Config>
  plugins = {},

  fn = {},
}
