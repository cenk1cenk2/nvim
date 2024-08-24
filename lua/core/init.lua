local M = {}

local path_sep = OS_UNAME == "windows" and "\\" or "/"

--- Checks if currently running in headless mode.
---@return boolean
function _G.is_headless()
  return #vim.api.nvim_list_uis() == 0 and #vim.tbl_filter(function(argv)
    if argv:find("sk.lua$") then
      return true
    end

    return false
  end, vim.v.argv) == 0
end

---Join path segments that were passed as input
---@vararg string
---@return string
function _G.join_paths(...)
  return table.concat({ ... }, path_sep)
end

---Get the full path to `$neovim_RUNTIME_DIR`
---@return string
function _G.get_data_dir()
  -- when nvim is used directly
  return vim.fn.stdpath("data")
end

---Get the full path to `$neovim_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  return vim.fn.stdpath("config")
end

---Get the full path to `$neovim_CONFIG_DIR`
---@return string
function _G.get_state_dir()
  return vim.fn.stdpath("state")
end

---Get the full path to `$neovim_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  return vim.fn.stdpath("cache")
end

--- Checks if given path is a file.
---@param path string
---@return boolean
function _G.is_file(path)
  local stat = vim.uv.fs_stat(path)

  return stat and stat.type == "file" or false
end

--- Checks if given path is a directory.
---@param path string
---@return boolean
function _G.is_directory(path)
  local stat = vim.uv.fs_stat(path)

  return stat and stat.type == "directory" or false
end

_G.OS_UNAME = string.lower(vim.loop.os_uname().sysname)

--- Checks if package is loaded.
---@param name string
---@return boolean
function _G.is_package_loaded(name)
  return package.loaded[name] ~= nil
end

--- Requires a module and returns it.
---@param m string
---@return any
function _G.require_clean(m)
  package.loaded[m] = nil
  _G[m] = nil
  local ok, module = pcall(require, m)
  if not ok then
    error(("Failed to load module: %s"):foramt(m))
  end

  return module
end

--- Gets the extension defined name in the extension module.
---@param module string
---@return string
function _G.get_extension_name(module)
  local ok, m = pcall(require, module)
  if not ok then
    error(("Failed to load extension: %s"):format(module))
  end

  return m.name
end

--- Checks if an extension is enabled.
---@param module string
---@return boolean
function _G.is_extension_enabled(module)
  local extension = require("setup").get_config(module) or {}
  if extension.enabled == nil then
    require("core.log"):error("Extension is not defined: %s", module)

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

  ---Get the full path to neovim's base directory
  -- FIXME: currently unreliable in unit-tests
  if not is_headless() then
    _G.PLENARY_DEBUG = false
  end

  require("core.loader").init()

  return self
end

--- Update the configuration repository.
function M:update()
  require("core.version").update_repository()
end

return M
