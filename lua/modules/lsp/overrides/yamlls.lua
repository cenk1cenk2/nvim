return {
  override = function(config)
    return require("yaml-companion").setup(config)
  end,
  -- Built in file matchers
  builtin_matchers = {
    -- Detects Kubernetes files based on content
    kubernetes = { enabled = true },
    cloud_init = { enabled = true },
  },
  -- Additional schemas available in Telescope picker
  schemas = {
    {
      name = "ArgoCD",
      uri = "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json",
    },
    {
      name = "Kubernetes master",
      uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
    },
    {
      name = "Kubernetes v1.27",
      uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.11-standalone-strict/all.json",
    },
    {
      name = "Kubernetes v1.29",
      uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.2-standalone-strict/all.json",
    },
    {
      name = "Gitlab CI",
      uri = "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json",
    },
  },
  lspconfig = {
    filetypes = {
      "yaml",
      "!yaml.ansible",
      "!yaml.docker-compose",
    },
    settings = {
      flags = {
        debounce_text_changes = 50,
      },
      redhat = { telemetry = { enabled = false } },
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        format = { enable = false },
        schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
        schemas = {
          kubernetes = {
            "templates/*!(.gitlab-ci).{yml,yaml}",
            "*.k8s.{yml,yaml}",
            "daemon.{yml,yaml}",
            "manager.{yml,yaml}",
            "restapi.{yml,yaml}",
            "*namespace*.{yml,yaml}",
            "role.{yml,yaml}",
            "role-binding.{yml,yaml}",
            "*onfigma*.{yml,yaml}",
            "*ingress*.{yml,yaml}",
            "*secret*.{yml,yaml}",
            "*deployment*.{yml,yaml}",
            "*service*.{yml,yaml}",
            "kubectl-edit*.yaml",
          },
          ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = { "*argocd*.{yml,yaml}" },
          ["http://json.schemastore.org/chart"] = { "Chart.{yml,yaml}" },
          ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
            ".gitlab-ci.yml",
          },
          ["https://json.schemastore.org/drone.json"] = { ".drone.yml" },
          ["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-playbook.json"] = {
            "deploy.yml",
            "provision.yml",
          },
          ["https://bitbucket.org/atlassianlabs/atlascode/raw/main/resources/schemas/pipelines-schema.json"] = {
            "bitbucket-pipelines.yml",
          },
          ["https://taskfile.dev/schema.json"] = {
            "Taskfile*.{yml,yaml}",
          },
          ["https://json.schemastore.org/pulumi.json"] = {
            "Pulumi.{yml,yaml}",
          },
          ["https://raw.githubusercontent.com/cenk1cenk2/docker-vizier/main/schema.json"] = {
            "vizier.{yml,yaml}",
          },
        },
      },
    },
  },
}
