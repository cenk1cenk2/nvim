require("lvim.bootstrap"):init()

require("lvim.config"):load()

require("lvim.plugins").load()

require("lvim.lsp").setup()
