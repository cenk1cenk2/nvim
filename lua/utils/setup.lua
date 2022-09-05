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

---@alias parsed_config { active: boolean, extension_name: string, inject: table<string, string>, condition: (fun(config: table): boolean), packer: table, to_inject: (fun(config: table): table<string, string>), autocmds: table, keymaps: table, wk: table, legacy_setup: table, setup: any | (fun(config: table): any), on_setup: (fun(config: table): nil), on_config_done: (fun(config: table): nil), set_injected: (fun(key: string, value: any): any), get_injected: (fun(key: string): any) }
---@alias config { condition: (fun(config: parsed_config): boolean | nil), packer: (fun(config: parsed_config): table), to_inject: (fun(config: parsed_config): table<string, string>), autocmds: table, keymaps: table, wk: table, legacy_setup: table, setup: table | (fun(config: parsed_config): any), on_setup: (fun(config: parsed_config): nil), on_config_done: (fun(config: parsed_config): nil) }

---
---@param extension_name string
---@param active boolean
---@param config config
function M.define_extension(extension_name, active, config)
  vim.validate {
    active = { active, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
    condition = { config.condition, "f", true },
    packer = { config.packer, "f", true },
    to_inject = { config.to_inject, "f", true },
    autocmds = { config.autocmds, "t", true },
    keymaps = { config.keymaps, "t", true },
    wk = { config.wk, "t", true },
    legacy_setup = { config.legacy_setup, "t", true },
    setup = { config.legacy_setup, { "t", "f" }, true },
  }

  lvim.extensions[extension_name] = {
    name = extension_name,
    active = active,
    inject = {},
    set_injected = function(key, value)
      lvim.extensions[extension_name].inject[key] = value

      return value
    end,
    get_injected = function(key)
      return lvim.extensions[extension_name].inject[key]
    end,
  }

  if config ~= nil and config.condition ~= nil and config.condition(lvim.extensions[extension_name]) == false then
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
---@param config parsed_config
function M.run(config)
  if config ~= nil and config.to_inject ~= nil then
    ---@diagnostic disable-next-line: assign-type-mismatch
    config.inject = vim.tbl_extend("force", config.inject, config.to_inject(config))
  end

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
