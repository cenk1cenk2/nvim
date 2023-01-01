local Pkg = require("mason-core.package")
local pip = require("mason-core.managers.pip3")
local helper = require("modules.lsp-config")

local server_name = "codespell"

helper.set_lsp_default_config(server_name, {
  command = { "codespell" },
})

helper.set_mason_registry(server_name, "modules-lsp.mason.codespell")

return Pkg.new({
  name = server_name,
  desc = [[Custom server description.]],
  homepage = "https://kilic.dev",
  categories = { Pkg.Cat.Formatter, Pkg.Cat.Linter },
  languages = { Pkg.Lang.Markdown },
  install = pip.packages({ "codespell", bin = { "codespell" } }),
})
