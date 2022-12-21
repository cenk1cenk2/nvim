require("lvim.bootstrap"):init()

require("lvim.config"):load()

require("utils.setup").set_plugins()
require("lvim.plugins").load { lvim.plugins }

require("lvim.lsp").setup()
