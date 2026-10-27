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
        local chart, file = M.chart_root(path)

        if chart or (not file and path:find("/templates/")) then
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
        local name = vim.fs.basename(path)
        local chart, file = M.chart_root(path)

        if (chart and vim.fs.relpath(chart, file):find("^templates/")) or (not file and path:find("/templates/")) then
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

--- Finds the chart a buffer belongs to, returned as `root, path`, where `path` is the file the lookup ran on.
--- Virtual buffers (`diffview://`, `gitsigns://`) keep the repository-relative path at the end of their name, so the
--- longest tail of the name whose directory exists in the cwd's repository stands in for it; `path` is nil when no tail does.
function M.chart_root(path)
  if vim.uv.fs_stat(vim.fs.dirname(path)) then
    return vim.fs.root(path, { "Chart.yaml" }), path
  end

  local repo = vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
  local segments = vim.split(path, "/", { trimempty = true })

  for i = 1, #segments - 1 do
    local tail = vim.fs.joinpath(repo, table.concat(segments, "/", i))
    local root = vim.uv.fs_stat(vim.fs.dirname(tail)) and vim.fs.root(tail, { "Chart.yaml" })

    if root then
      return root, tail
    end
  end
end

return M
