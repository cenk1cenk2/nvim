local opts = {
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemaStore = {enable = true, url = 'https://www.schemastore.org/api/json/catalog.json'},
      schemas = {
        kubernetes = {
          'daemon.{yml,yaml}',
          'manager.{yml,yaml}',
          'restapi.{yml,yaml}',
          'role.{yml,yaml}',
          'role_binding.{yml,yaml}',
          '*onfigma*.{yml,yaml}',
          '*ngres*.{yml,yaml}',
          '*ecre*.{yml,yaml}',
          '*eployment*.{yml,yaml}',
          '*ervic*.{yml,yaml}',
          'kubectl-edit*.yaml'
        },
        ['https://json.schemastore.org/gitlab-ci.json'] = {'.gitlab-ci.yml'},
        ['https://json.schemastore.org/drone.json'] = {'.drone.yml'},
        ['https://json.schemastore.org/ansible-playbook.json'] = {'deploy.yml', 'provision.yml'},
        ['https://bitbucket.org/atlassianlabs/atlascode/raw/main/resources/schemas/pipelines-schema.json'] = {'bitbucket-pipelines.yml'}
      }
    }
  }
}

return opts
