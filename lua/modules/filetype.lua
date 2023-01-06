local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        vim.bo.indentexpr = "nvim_treesitter#indent()"

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
        local root = require("lspconfig/util").root_pattern("ansible.cfg", ".ansible-lint", ".vault-password")(path)

        if root and not (path:find("environments/") or path:find("vars/")) and vim.fs.dirname(path) ~= root then
          return "yaml.ansible"
        end

        return "yaml"
      end,
    },
  })
end

return M
