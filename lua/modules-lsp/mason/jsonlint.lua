local Pkg = require "mason-core.package"
local npm = require "mason-core.managers.npm"
local helper = require "modules.lsp-config"

local server_name = "jsonlint"

helper.set_lsp_default_config(server_name, {
  command = { "jsonlint" },
})

helper.set_mason_registry(server_name, "modules-lsp.mason.jsonlint")

return Pkg.new {
  name = server_name,
  desc = [[Custom server description.]],
  homepage = "https://kilic.dev",
  categories = { Pkg.Cat.Formatter },
  languages = { Pkg.Lang.Json },
  install = npm.packages { "jsonlint", bin = { "jsonlint" } },
}
