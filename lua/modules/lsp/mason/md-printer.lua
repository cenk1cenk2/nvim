local Pkg = require("mason-core.package")
local npm = require("mason-core.managers.npm")
local helper = require("modules.lsp-config")

local server_name = "md-printer"

helper.set_lsp_default_config(server_name, {
  command = { "md-printer" },
})

helper.set_mason_registry(server_name, "modules.lsp.mason.md-printer")

return Pkg.new({
  name = server_name,
  desc = [[Custom server description.]],
  homepage = "https://kilic.dev",
  categories = { Pkg.Cat.Formatter },
  languages = { Pkg.Lang.Markdown },
  install = npm.packages({ "@cenk1cenk2/md-printer", bin = { "md-printer" } }),
})
