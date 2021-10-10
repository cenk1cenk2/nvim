local M = {}

package.loaded['utils.hooks'] = nil
local _, hooks = pcall(require, 'utils.hooks')

---Join path segments that were passed as input
---@return string
function _G.join_paths(...)
  local uv = vim.loop
  local path_sep = uv.os_uname().version:match 'Windows' and '\\' or '/'
  local result = table.concat({...}, path_sep)
  return result
end

---Get the full path to `$LUNARVIM_RUNTIME_DIR`
---@return string
function _G.get_runtime_dir()
  -- when nvim is used directly
  return vim.fn.stdpath('data')
end

---Get the full path to `$LUNARVIM_CONFIG_DIR`
---@return string
function _G.get_config_dir()
  return vim.fn.stdpath 'config'
end

---Get the full path to `$LUNARVIM_CACHE_DIR`
---@return string
function _G.get_cache_dir()
  return vim.fn.stdpath 'cache'
end

---Get the full path to the currently installed lunarvim repo
---@return string
local function get_install_path()
  -- when nvim is used directly
  return vim.fn.stdpath 'config'
end

---Get currently installed version of LunarVim
---@param type string can be "short"
---@return string
function _G.get_version(type)
  type = type or ''
  local lvim_full_ver = vim.fn.system('git -C ' .. get_install_path() .. ' describe --tags')

  if string.match(lvim_full_ver, '%d') == nil then return nil end
  if type == 'short' then
    return vim.fn.split(lvim_full_ver, '-')[1]
  else
    return string.sub(lvim_full_ver, 1, #lvim_full_ver - 1)
  end
end

---Initialize the `&runtimepath` variables and prepare for startup
---@return table
function M:init()
  self.runtime_dir = get_runtime_dir()
  self.config_dir = get_config_dir()
  self.cache_path = get_cache_dir()
  self.install_path = get_install_path()

  self.pack_dir = join_paths(self.runtime_dir, 'site', 'pack')
  self.packer_install_dir = join_paths(self.runtime_dir, 'site', 'pack', 'packer', 'start', 'packer.nvim')
  self.packer_cache_path = join_paths(self.config_dir, 'plugin', 'packer_compiled.lua')

  vim.fn.mkdir(vim.fn.stdpath 'cache', 'p')

  local config = require 'config'
  config:init{path = join_paths(self.config_dir, 'config.lua')}

  require('plugin-loader'):init{package_root = self.pack_dir, install_path = self.packer_install_dir}

  return self
end

---Update LunarVim
---pulls the latest changes from github and, resets the startup cache
function M:update()
  hooks.run_pre_update()
  M:update_repo()
  hooks.run_post_update()
end

local function git_cmd(subcmd)
  local Job = require 'plenary.job'
  local Log = require 'core.log'
  local args = {'-C', get_install_path()}
  vim.list_extend(args, subcmd)

  local stderr = {}
  local stdout, ret = Job:new({
    command = 'git',
    args = args,
    cwd = get_install_path(),
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end
  }):sync()

  if not vim.tbl_isempty(stderr) then Log:debug(stderr) end

  if not vim.tbl_isempty(stdout) then Log:debug(stdout) end

  return ret
end

---pulls the latest changes from github
function M:update_repo()
  local Log = require 'core.log'
  local sub_commands = {fetch = {'fetch'}, diff = {'diff', '--quiet', '@{upstream}'}, merge = {'merge', '--ff-only', '--progress'}}
  Log:info 'Checking for updates'

  local ret = git_cmd(sub_commands.fetch)
  if ret ~= 0 then
    Log:error 'Update failed! Check the log for further information'
    return
  end

  ret = git_cmd(sub_commands.diff)

  if ret == 0 then
    Log:info 'Configuration is already up-to-date'
    return
  end

  ret = git_cmd(sub_commands.merge)

  if ret ~= 0 then
    Log:error 'Update failed! Please pull the changes manually instead.'
    return
  end
end

return M
