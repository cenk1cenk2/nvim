-- HACK: should be removed whenever plugins gets updated
vim.deprecate = function() end

require("lvim.bootstrap"):init()

require("lvim.config"):load()

require("lvim.plugin-loader").load()
