local opts = {
  filetypes = {
    "yaml",
    -- "yaml.ansible",
  },
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
      schemas = {
        kubernetes = {
          "daemon.{yml,yaml}",
          "manager.{yml,yaml}",
          "restapi.{yml,yaml}",
          "role.{yml,yaml}",
          "role_binding.{yml,yaml}",
          "*onfigma*.{yml,yaml}",
          "*ngres*.{yml,yaml}",
          "*ecre*.{yml,yaml}",
          "*eployment*.{yml,yaml}",
          "*ervic*.{yml,yaml}",
          "kubectl-edit*.yaml",
        },
        ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
          ".gitlab-ci.yml",
        },
        ["https://json.schemastore.org/drone.json"] = { ".drone.yml" },
        -- ["https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-playbook.json"] = {
        --   "deploy.yml",
        --   "provision.yml",
        -- },
        ["https://bitbucket.org/atlassianlabs/atlascode/raw/main/resources/schemas/pipelines-schema.json"] = {
          "bitbucket-pipelines.yml",
        },
      },
    },
  },
}

return opts
