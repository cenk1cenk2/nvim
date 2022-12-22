local Pkg = require("mason-core.package")
local npm = require("mason-core.managers.npm")
local helper = require("modules.lsp-config")

local server_name = "rustywind"

helper.set_lsp_default_config(server_name, {
  command = { "rustywind" },
})

helper.set_mason_registry(server_name, "modules-lsp.mason.rustywind")

return Pkg.new({
  name = server_name,
  desc = [[Custom server description.]],
  homepage = "https://kilic.dev",
  categories = { Pkg.Cat.Formatter },
  languages = { Pkg.Lang.Html },
  install = npm.packages({ "rustywind", bin = { "rustywind" } }),
})
