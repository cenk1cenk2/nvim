local M = {}

local setup = require "utils.setup"

local extension_name = "coc"

function M.config()
  setup.define_extension(extension_name, true, {
    legacy_setup = {
      coc_start_at_startup = true,
      coc_suggest_disable = 1,
      coc_global_extensions = {
        "coc-lists",
        "coc-marketplace",
        "coc-gitignore",
        "coc-gist",
      },
    },
  })
end

function M.setup()
  local config = setup.get_config(extension_name)

  setup.legacy_setup(config.legacy_setup)

  setup.on_setup_done(config)
end

return M
