local M = {}

if vim.fn.has "nvim-0.6.1" ~= 1 then
  vim.notify("Please upgrade your Neovim base installation. Lunarvim requires v0.6.1+", vim.log.levels.WARN)
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

---Get the full path to the currently installed lunarvim repo
---@return string
local function get_install_path()
  -- when nvim is used directly
  return vim.fn.stdpath "config"
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

  vim.cmd [[let &packpath = &runtimepath]]
  vim.cmd("set spellfile=" .. join_paths(self.config_dir, "spell", "en.utf-8.add"))
  ---Get the full path to LunarVim's base directory
  ---@return string
  function _G.get_lvim_base_dir()
    return base_dir
  end

  if os.getenv "LUNARVIM_RUNTIME_DIR" then
    -- vim.opt.rtp:append(os.getenv "LUNARVIM_RUNTIME_DIR" .. path_sep .. "lvim")
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site"))
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "data", "site", "after"))
    vim.opt.rtp:prepend(join_paths(self.runtime_dir, "site"))
    vim.opt.rtp:append(join_paths(self.runtime_dir, "site", "after"))

    vim.opt.rtp:remove(vim.fn.stdpath "config")
    vim.opt.rtp:remove(join_paths(vim.fn.stdpath "config", "after"))
    vim.opt.rtp:prepend(self.config_dir)
    vim.opt.rtp:append(join_paths(self.config_dir, "after"))
    -- TODO: we need something like this: vim.opt.packpath = vim.opt.rtp

    vim.cmd [[let &packpath = &runtimepath]]
  end

  -- FIXME: currently unreliable in unit-tests
  if not in_headless then
    _G.PLENARY_DEBUG = false
    --   require("lvim.impatient").setup {
    --     path = join_paths(self.cache_dir, "lvim_cache"),
    --     enable_profiling = true,
    --   }
  end

  require("lvim.config"):init()

  require("lvim.plugin-loader").init {
    package_root = self.pack_dir,
    install_path = self.packer_install_dir,
  }

  return self
end

---Update LunarVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  require_clean("lvim.utils.hooks").run_pre_update()
  require_clean("lvim.utils.git").update_base_lvim()
  require_clean("lvim.utils.hooks").run_post_update()
end

return M
