local M = {}

function M.setup()
  vim.filetype.add({
    extension = {
      ["j2"] = function()
        return "jinja"
      end,
      ["tf"] = "terraform",
      ["tfvars"] = "terraform",
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
      [".*%.g?o?tm?pl"] = function(path)
        if vim.fs.root(M.resolve_path(path), { "Chart.yaml" }) then
          return "helm"
        end

        return "gotmpl"
      end,
      ["Dockerfile.*"] = function(path)
        if path:find("%.dockerignore$") then
          return "gitignore"
        end

        return "dockerfile"
      end,
      [".*%.dockerignore"] = "gitignore",
      ["neomutt-.*"] = "markdown",
      [".*%.ya?ml"] = function(path)
        path = M.resolve_path(path)
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

--- Maps `diffview://<gitdir>/<rev>/<path>` buffers back to the file in the working tree.
function M.resolve_path(path)
  -- detection receives the name made absolute against the cwd, `<cwd>/diffview:/<gitdir>/...`
  local rest = path:match("diffview:/*(/.*)$")
  if not rest then
    return path
  end

  local gitdir, rel = rest:match("^(.-/%.git/worktrees/[^/]+)/[^/]+/(.*)$")
  if gitdir then
    return vim.fs.joinpath(vim.fs.dirname(vim.trim(vim.fn.readfile(vim.fs.joinpath(gitdir, "gitdir"))[1])), rel)
  end

  local toplevel
  toplevel, rel = rest:match("^(.-)/%.git/[^/]+/(.*)$")

  return toplevel and vim.fs.joinpath(toplevel, rel) or path
end

return M
