local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        vim.opt_local.indentexpr = "GetDjangoIndent()"

        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
      ["zsh"] = "sh",
    },
    filename = {
      [".editorconfig"] = "toml",
      [".rgignore"] = "gitignore",
      [".npmignore"] = "gitignore",
      [".prettierignore"] = "gitignore",
      [".eslintignore"] = "gitignore",
      [".dockerignore"] = "gitignore",
      ["tsconfig.json"] = "jsonc",
      [".prettierrc"] = "json",
      [".eslintrc"] = "json",
      [".babelrc"] = "json",
    },
    pattern = {
      ["Dockerfile.*"] = "dockerfile",
      [".*%.yml"] = function(path)
        if path:find("docker%-compose.*$") then
          return "yaml.docker-compose"
        end

        local root = require("lspconfig/util").root_pattern("ansible.cfg", ".ansible-lint", ".vault-password")(path)

        if root and not (path:find("environments/") or path:find("vars/") or path:find("group_vars/") or path:find("host_vars/")) and vim.fs.dirname(path) ~= root then
          return "yaml.ansible"
        end

        return "yaml"
      end,
    },
  })
end

return M
