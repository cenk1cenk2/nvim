local M = {}

local extension_name = "session_manager"
local utils = require "lvim.utils"

function M.config()
  local session_manager_config_ok, session_manager_config = pcall(require, "session_manager.config")

  if not session_manager_config_ok then
    return
  end

  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
  }

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], {
    setup = {
      sessions_dir = utils.join_paths(get_runtime_dir(), "sessions"), -- The directory where the session files will be saved.
      path_replacer = "__", -- The character to which the path separator will be replaced for session files.
      colon_replacer = "++", -- The character to which the colon symbol will be replaced for session files.
      autoload_mode = session_manager_config.AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
      autosave_last_session = true, -- Automatically save last session on exit.
      autosave_ignore_not_normal = false, -- Plugin will not save a session when no writable and listed buffers are opened.
      autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
    },
  })
end

function M.setup()
  local extension = require(extension_name)
  extension.setup(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
