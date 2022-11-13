local M = {}

if vim.fn.has "nvim-0.7" ~= 1 then
  vim.notify("Please upgrade your Neovim base installation. Lunarvim requires v0.7+", vim.log.levels.WARN)
  vim.wait(5000, function()
    return false
  end)
  vim.cmd "cquit"
end

local uv = vim.loop
local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"
local in_headless = #vim.api.nvim_list_uis() == 0

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
function _G.get_runtime_dir()
  -- when nvim is used directly
  return vim.fn.stdpath "data"
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  return vim.fn.stdpath "config"
end

---Get the full path to `$LUNARVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  return vim.fn.stdpath "cache"
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init(base_dir)
  self.runtime_dir = get_runtime_dir()
  self.config_dir = get_config_dir()
  self.cache_dir = get_cache_dir()
  self.pack_dir = join_paths(self.runtime_dir, "site", "pack")
  self.packer_install_dir = join_paths(self.runtime_dir, "site", "pack", "packer", "start", "packer.nvim")
  self.packer_cache_path = join_paths(self.config_dir, "plugin", "packer_compiled.lua")

  ---Get the full path to LunarVim's base directory
  ---@return string
  function _G.get_lvim_base_dir()
    return base_dir
  end

  -- FIXME: currently unreliable in unit-tests
  if not in_headless then
    _G.PLENARY_DEBUG = false
    require "lvim.impatient"
  end

  require("lvim.plugin-loader").init {
    package_root = self.pack_dir,
    install_path = self.packer_install_dir,
  }

  require("lvim.config"):init()

  return self
end

---Update LunarVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  require_clean("lvim.utils.hooks").run_pre_update()
  local ret = require_clean("lvim.utils.git").update_base_lvim()
  if ret then
    require_clean("lvim.utils.hooks").run_post_update()
  end
end

return M
