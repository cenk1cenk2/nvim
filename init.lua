require("lvim.bootstrap"):init()

require("lvim.config"):load()

require("lvim.plugin-loader").load()

require("lvim.lsp").setup()
