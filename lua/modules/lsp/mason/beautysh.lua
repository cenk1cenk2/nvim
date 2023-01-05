local Pkg = require("mason-core.package")
local pip = require("mason-core.managers.pip3")
local helper = require("modules.lsp-config")

local server_name = "beautysh"

helper.set_lsp_default_config(server_name, {
  command = { "beautysh" },
  args = { "--indent-size", "2" },
})

helper.set_mason_registry(server_name, "modules.lsp.mason.beautysh")

return Pkg.new({
  name = server_name,
  desc = [[Custom server description.]],
  homepage = "https://kilic.dev",
  categories = { Pkg.Cat.Formatter },
  languages = { Pkg.Lang.Bash },
  install = pip.packages({ "beautysh", bin = { "beautysh" } }),
})
