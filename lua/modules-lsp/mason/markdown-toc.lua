local Pkg = require "mason-core.package"
local npm = require "mason-core.managers.npm"
local helper = require "modules.lsp-config"

local server_name = "markdown-toc"

helper.set_lsp_default_config(server_name, {
  command = { "markdown-toc" },
  args = { "--bullets=-", "-i" },
})

helper.set_mason_registry(server_name, "modules-lsp.mason.markdown-toc")

return Pkg.new {
  name = server_name,
  desc = [[Custom server description.]],
  homepage = "https://kilic.dev",
  categories = { Pkg.Cat.Formatter },
  languages = { Pkg.Lang.Markdown },
  install = npm.packages { "markdown-toc", bin = { "markdown-toc" } },
}
