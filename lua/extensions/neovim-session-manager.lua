-- https://github.com/Shatur/neovim-session-manager

local setup = require "utils.setup"
local utils = require "lvim.utils"

local M = {}

local extension_name = "session_manager"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "Shatur/neovim-session-manager",
        config = function()
          require("utils.setup").packer_config "session_manager"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        session_manager_config = require "session_manager.config",
      }
    end,
    setup = function(config)
      return {
        sessions_dir = utils.join_paths(get_runtime_dir(), "sessions"), -- The directory where the session files will be saved.
        path_replacer = "__", -- The character to which the path separator will be replaced for session files.
        colon_replacer = "++", -- The character to which the colon symbol will be replaced for session files.
        autoload_mode = config.inject.session_manager_config.AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autosave_last_session = true, -- Automatically save last session on exit.
        autosave_ignore_not_normal = false, -- Plugin will not save a session when no writable and listed buffers are opened.
        autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
      }
    end,
    on_setup = function(config)
      require("session_manager").setup(config.setup)
    end,
  })
end

return M
