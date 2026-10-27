local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
      ["gotmpl"] = M.detect_go_template,
      ["tmpl"] = M.detect_go_template,
      ["tpl"] = M.detect_go_template,
      ["http"] = "http",
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
        if path:find("%.dockerignore$") then
          return "gitignore"
        end

        return "dockerfile"
      end,
      [".*%.dockerignore"] = "gitignore",
      ["neomutt-.*"] = "markdown",
      [".*%.ya?ml"] = function(path)
        local name = vim.fs.basename(path)
        local chart = vim.fs.root(path, { "Chart.yaml" })

        if chart and vim.fs.relpath(chart, path):find("^templates/") then
          return "helm"
        elseif name:find("%.gitlab%-ci%.") then
          return "yaml.gitlab-ci"
        elseif name:find("compose") then
          return "yaml.compose"
        elseif not chart then
          local root = vim.fs.root(path, { "ansible.cfg", ".ansible-lint", ".vault-password" })

          if
            root
            and vim.fs.dirname(path) ~= root
            and not vim.iter(vim.fs.dirname(vim.fs.relpath(root, path)):gmatch("[^/]+")):any(function(dir)
              return vim.tbl_contains({ "environments", "vars", "group_vars", "host_vars", "files", "templates" }, dir)
            end)
          then
            return "yaml.ansible"
          end
        end

        return "yaml"
      end,
    },
  })
end

function M.detect_go_template(path)
  if vim.fs.root(path, { "Chart.yaml" }) then
    return "helm"
  end

  return "gotmpl"
end

return M
