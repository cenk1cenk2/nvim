local M = {}

local extension_name = "dressing"

function M.config()
  local telescope_ok, telescope = pcall(require, "telescope.themes")

  if not telescope_ok then
    lvim.extensions[extension_name] = {
      active = true,
    }

    return
  end

  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      input = {
        -- Default prompt string
        default_prompt = "➤ ",

        -- When true, <Esc> will close the modal
        insert_only = true,

        -- These are passed to nvim_open_win
        anchor = "SW",
        relative = "cursor",
        border = "single",

        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        prefer_width = 40,
        max_width = nil,
        min_width = 20,

        -- Window transparency (0-100)
        winblend = 0,

        -- see :help dressing-prompt
        prompt_buffer = false,

        -- see :help dressing_get_config
        get_config = nil,
      },
      select = {
        -- Priority list of preferred vim.select implementations
        backend = { "telescope", "fzf", "builtin", "nui" },

        -- Options for telescope selector
        telescope = telescope.get_dropdown {},

        -- see :help dressing_get_config
        get_config = nil,
      },
    },
  }
end

function M.setup()
  local extension = require(extension_name)

  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
