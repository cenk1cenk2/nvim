local M = {}

local uv = vim.uv
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

function _G.is_headless()
  return #vim.api.nvim_list_uis() == 0 and #vim.tbl_filter(function(argv)
    if argv:find("sk.lua$") then
      return true
    end

    return false
  end, vim.v.argv) == 0
end

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

---Get the full path to `$LUNARVIM_RUNTIME_DIR`
---@return string | string[]
function _G.get_data_dir()
  -- when nvim is used directly
  return vim.fn.stdpath("data")
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string | string[]
function _G.get_config_dir()
  return vim.fn.stdpath("config")
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string | string[]
function _G.get_state_dir()
  return vim.fn.stdpath("state")
end

---Get the full path to `$LUNARVIM_CACHE_DIR`
---@return string | string[]
function _G.get_cache_dir()
  return vim.fn.stdpath("cache")
end

function _G.is_file(path)
  local stat = vim.uv.fs_stat(path)

  return stat and stat.type == "file" or false
end

function _G.is_directory(path)
  local stat = vim.uv.fs_stat(path)

  return stat and stat.type == "directory" or false
end

_G.OS_UNAME = string.lower(vim.loop.os_uname().sysname)

function _G.is_package_loaded(name)
  return package.loaded[name] ~= nil
end

function _G.get_extension_name(module)
  local ok, m = pcall(require, module)
  if not ok then
    require("lvim.log"):error("Failed to load extension: %s", module)

    return nil
  end

  return m.name
end

--- Checks if an extension is enabled.
---@param module string
---@return boolean
function _G.is_extension_enabled(module)
  local extension = require("utils.setup").get_config(module) or {}
  if extension.enabled == nil then
    require("lvim.log"):error("Extension is not defined: %s", module)

    return false
  end

  return extension.enabled
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

  require("lvim.loader").init()

  require("lvim.config"):init()

  return self
end

---Update LunarVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  require("lvim.version").update_repository()
end

return M
