---@type vim.lsp.ClientConfig
return {
  override = function(config)
    return require("schema-companion").setup_client(
      require("schema-companion").adapters.yamlls.setup({
        sources = {
          require("schema-companion").sources.matchers.kubernetes.setup({ version = "master" }),
          require("schema-companion").sources.lsp.setup(),
          require("schema-companion").sources.schemas.setup({
            {
              name = "Kubernetes master",
              uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json",
            },
            {
              name = "Kubernetes v1.27",
              uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.16-standalone-strict/all.json",
            },
            {
              name = "Kubernetes v1.28",
              uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.28.12-standalone-strict/all.json",
            },
            {
              name = "Kubernetes v1.29",
              uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.7-standalone-strict/all.json",
            },
            {
              name = "Kubernetes v1.30",
              uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.3-standalone-strict/all.json",
            },
          }),
        },
      }),
      config
    )
  end,
  on_attach = function(client, bufnr)
    require("ck.lsp.handlers").on_attach(client, bufnr)
    require("ck.lsp.handlers").overwrite_capabilities_with_no_formatting(client, bufnr)
  end,
  filetypes = {
    "yaml",
    "yaml.gitlab-ci",
    "yaml.compose",
    "!yaml.ansible",
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
      customTags = {
        "!reference sequence",
        "!environment sequence",
      },
      editor = {
        formatOnType = false,
      },
      schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
      schemaDownload = { enable = true },
      schemas = vim.tbl_extend("force", require("schemastore").yaml.schemas(), {
        -- kubernetes = {
        --   "templates/*!(.gitlab-ci).{yml,yaml}",
        --   "workloads/**/*!(kustomization).{yml,yaml}",
        --   "*.k8s.{yml,yaml}",
        --   "daemon.{yml,yaml}",
        --   "manager.{yml,yaml}",
        --   "restapi.{yml,yaml}",
        --   "*namespace*.{yml,yaml}",
        --   "role.{yml,yaml}",
        --   "role-binding.{yml,yaml}",
        --   "*onfigma*.{yml,yaml}",
        --   "*ingress*.{yml,yaml}",
        --   "*secret*.{yml,yaml}",
        --   "*deployment*.{yml,yaml}",
        --   "*service*.{yml,yaml}",
        --   "kubectl-edit*.yaml",
        -- },
        ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = { "*argocd*.{yml,yaml}" },
        ["http://json.schemastore.org/chart"] = { "Chart.{yml,yaml}" },
        ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
          ".gitlab-ci.{yml,yaml}",
          ".gitlab-ci.*.{yml,yaml}",
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
          "Taskfile.*.{yml,yaml}",
        },
        ["https://json.schemastore.org/pulumi.json"] = {
          "Pulumi.{yml,yaml}",
        },
        ["https://raw.githubusercontent.com/cenk1cenk2/docker-vizier/main/schema.json"] = {
          "vizier.{yml,yaml}",
        },
        ["https://json.schemastore.org/json-patch.json"] = {
          "jsonpatch-*.{yml,yaml}",
          "*-jsonpatch.{yml,yaml}",
          "json-patch-*.{yml,yaml}",
          "*-json-patch.{yml,yaml}",
        },
      }),
    },
  },
}
