return {
  filetypes = {
    "yaml",
    "helm",
    "!yaml.ansible",
    "!yaml.docker-compose",
  },
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
      schemas = {
        kubernetes = {
          "templates/*.{yml,yaml}",
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
        ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = { "*flow*.{yml,yaml}" },
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
      },
    },
  },
}
