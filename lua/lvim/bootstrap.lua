local M = {}

local uv = vim.loop
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

function _G.is_headless()
  return #vim.api.nvim_list_uis() == 0
end

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

---Require a module in protected mode without relying on its cached value
---@param module string
---@return any
function _G.require_clean(module)
  package.loaded[module] = nil
  _G[module] = nil
  local _, requested = pcall(require, module)
  return requested
end

---Get the full path to `$LUNARVIM_RUNTIME_DIR`
---@return string
function _G.get_data_dir()
  -- when nvim is used directly
  return vim.fn.stdpath("data")
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  return vim.fn.stdpath("config")
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string
function _G.get_state_dir()
  return vim.fn.stdpath("state")
end

---Get the full path to `$LUNARVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  return vim.fn.stdpath("cache")
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init()
  self.runtime_dir = get_data_dir()
  self.config_dir = get_config_dir()
  self.cache_dir = get_cache_dir()

  ---Get the full path to LunarVim's base directory
  -- FIXME: currently unreliable in unit-tests
  if not is_headless() then
    _G.PLENARY_DEBUG = false
  end

  require("lvim.plugin-loader").init()

  require("lvim.config"):init()

  return self
end

---Update LunarVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  require_clean("lvim.utils.hooks").run_pre_update()

  local ret = require_clean("lvim.utils.git").update_repository()

  if ret then
    require_clean("lvim.utils.hooks").run_post_update()
  end
end

return M
