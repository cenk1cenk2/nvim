local M = {}

function M.setup()
  vim.filetype.add {
    extension = {
      ["j2"] = function()
        vim.bo.indentexpr = "nvim_treesitter#indent()"

        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
      ["zsh"] = "sh",
      ["qf"] = function()
        vim.cmd [[wincmd J]]
      end,
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
        local ansible_project = vim.fs.find(
          { "ansible.cfg", ".ansible-lint", ".vault-password" },
          { path = vim.fs.dirname(path), type = "file" }
        )

        if ansible_project and #ansible_project > 0 then
          return "yaml.ansible"
        end

        return "yaml"
      end,
    },
  }
end

return M
