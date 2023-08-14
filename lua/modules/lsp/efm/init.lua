local M = {}

function M.setup()
  local efm = require("lvim.lsp.efm")

  efm.register(efm.load("prettierd"), {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
    "yaml",
    "yaml.ansible",
    "yaml.docker-compose",
    "json",
    "jsonc",
    "html",
    "scss",
    "css",
    "markdown",
    "graphql",
    "helm",
  })

  efm.register(efm.load("eslint_d"), {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
  })

  efm.register(efm.load("stylua"), {
    "lua",
  })

  efm.register(efm.load("golines"), {
    "go",
  })
  efm.register(efm.load("goimports"), {
    "go",
  })

  efm.register(efm.load("shfmt"), {
    "sh",
    "bash",
    "zsh",
  })
  efm.register(efm.load("beautysh"), {
    "sh",
    "bash",
    "zsh",
  })
  efm.register(efm.load("shellcheck"), {
    "sh",
    "bash",
    "zsh",
  })

  efm.register(efm.load("hadolint"), {
    "dockerfile",
  })
end

return M
