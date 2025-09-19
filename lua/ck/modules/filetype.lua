local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
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
      [".gitlab-ci.yml"] = "yaml.gitlab-ci",
    },
    pattern = {
      ["Dockerfile.*"] = function(path)
        if path:find(".dockerignore*$") then
          return "gitignore"
        end

        return "dockerfile"
      end,
      [".*.dockerignore"] = "gitignore",
      ["neomutt-.*"] = "markdown",
      [".*%.ya?ml"] = function(path)
        if path:find(".*%.gitlab-ci%..*$") then
          return "yaml.gitlab-ci"
        elseif path:find(".*compose.*$") then
          return "yaml.compose"
        elseif
          vim.fs.root(path, { "ansible.cfg", ".ansible-lint", ".vault-password" })
          and not (path:find("environments/") or path:find("vars/") or path:find("group_vars/") or path:find("host_vars/") or path:find("files/") or path:find("templates/"))
          and vim.fs.dirname(path) ~= vim.fs.root(path, { "ansible.cfg", ".ansible-lint", ".vault-password" })
        then
          return "yaml.ansible"
        elseif vim.fs.root(path, { "Chart.yaml" }) and path:find("templates/") then
          return "helm"
        end

        return "yaml"
      end,
    },
  })
end

return M
