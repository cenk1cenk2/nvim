local Log = require "lvim.core.log"
local M = {}

local keymappings = require "lvim.keymappings"
---
---@param mappings table
function M.load_wk_mappings(mappings)
  for key, value in pairs(mappings) do
    lvim.builtin.which_key.mappings[key] = vim.tbl_deep_extend("force", lvim.builtin.which_key.mappings[key], value)
  end
end

---
---@param mappings table
function M.load_mappings(mappings)
  for key, mapping in pairs(mappings) do
    local clone = vim.deepcopy(mapping)
    local modes = table.remove(clone, 1)

    for _, mode in pairs(modes) do
      keymappings.load_mode(mode, { [key] = clone })
    end
  end
end

---
---@param opts table
function M.legacy_setup(opts)
  for opt, val in pairs(opts) do
    vim.g[opt] = val
  end
end

---
---@param extension_name string
---@param active boolean
---@param config table
---@param opts table?
function M.define_extension(extension_name, active, config, opts)
  vim.validate {
    active = { active, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
  }

  lvim.extensions[extension_name] = {
    active = active,
    inject = {},
  }

  if opts ~= nil and opts.condition ~= nil and opts.condition(lvim.extensions[extension_name]) == false then
    Log:debug(string.format("Extension config stopped due to failed condition: %s", extension_name))

    return
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], config)

  if config ~= nil and config.packer ~= nil then
    lvim.extensions[extension_name].packer = config.packer(lvim.extensions[extension_name])
  end
end

---
---@param extension_name string
---@return table
function M.get_config(extension_name)
  return lvim.extensions[extension_name]
end

---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
  require("lvim.core.autocmds").define_autocmds(definitions)
end

---
---@param extension_name string
function M.packer_config(extension_name)
  return M.run(M.get_config(extension_name))
end

---
---@param config table
function M.run(config)
  if config ~= nil and config.autocmds ~= nil then
    M.define_autocmds(config.autocmds)
  end

  if config ~= nil and config.keymaps ~= nil then
    M.load_mappings(config.keymaps)
  end

  if config ~= nil and config.wk ~= nil then
    M.load_wk_mappings(config.wk)
  end

  if config ~= nil and config.legacy_setup ~= nil then
    M.legacy_setup(config.legacy_setup)
  end

  if config ~= nil and config.setup ~= nil and type(config.setup) == "function" then
    config.setup = config.setup(config)
  end

  if config ~= nil and config.on_setup ~= nil then
    config.on_setup(config)
  end

  if config ~= nil and config.on_config_done ~= nil then
    config.on_config_done(config)
  end
end

---
---@param extension_name string
---@return table
function M.packer(extension_name)
  return M.get_config(extension_name).packer
end

---
function M.set_packer_extensions()
  local packer = {}
  for _, extension in pairs(lvim.extensions) do
    if extension.packer ~= nil then
      table.insert(packer, extension.packer)
    end
  end

  lvim.plugins = packer
end

return M
