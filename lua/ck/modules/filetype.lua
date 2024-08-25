local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
      ["zsh"] = "sh",
      ["go.tmpl"] = "gotmpl",
      ["gotmpl"] = "gotmpl",
      ["tmpl"] = "gotmpl",
      ["http"] = "http",
      ["tpl"] = function(path)
        if path:find("templates/") then
          return "helm"
        end

        return "gotmpl"
      end,
    },
    filename = {
      -- [".editorconfig"] = "toml",
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
      ["Dockerfile.*"] = function(path)
        if path:find(".dockerignore*$") then
          return "gitignore"
        end

        return "dockerfile"
      end,
      ["*.dockerignore"] = "gitignore",
      [".*%.yml"] = function(path)
        if path:find(".*compose.*$") then
          return "yaml.docker-compose"
        end

        local ansible_root = vim.fs.root(path, { "ansible.cfg", ".ansible-lint", ".vault-password" })

        if
          ansible_root
          and not (path:find("environments/") or path:find("vars/") or path:find("group_vars/") or path:find("host_vars/"))
          and vim.fs.dirname(path) ~= ansible_root
        then
          return "yaml.ansible"
        end

        return "yaml"
      end,
      [".*%.yaml"] = function(path)
        if vim.fs.root(path, { "Chart.yaml" }) and path:find("templates/") then
          return "helm"
        end

        return "yaml"
      end,
    },
  })
end

return M
