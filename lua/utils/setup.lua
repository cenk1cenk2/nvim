local Log = require "lvim.core.log"
local M = {}

local keymappings = require "lvim.keymappings"
---
---@param mappings table
function M.load_wk_mappings(mappings)
  for key, value in pairs(mappings) do
    lvim.builtin.which_key.mappings[key] =
      vim.tbl_deep_extend("force", lvim.builtin.which_key.mappings[key] or {}, value)
  end
end

---
---@param mappings table
function M.load_mappings(mappings)
  keymappings.load(mappings)
end

---
---@param opts table
function M.legacy_setup(opts)
  for opt, val in pairs(opts) do
    vim.g[opt] = val
  end
end

---@alias config { name: string, active: boolean, store: table<string, any>, extension_name: string, inject: table<string, string>, condition: (fun(config: table): boolean), packer: table, to_inject: (fun(config: table): table<string, string>), autocmds: table, keymaps: table | (fun(config:table):any), wk: table, legacy_setup: table, setup: any | (fun(config: table): any), on_setup: (fun(config: table): nil), on_done: (fun(config: table): nil), set_injected: (fun(key: string, value: any): any), set_store: (fun(key: string, value: any): any) }

---
---@param extension_name string
---@param active boolean
---@param config { on_init: (fun(config: config): nil) ,condition: (fun(config: config): boolean | nil), packer: (fun(config: config): table), to_inject: (fun(config: config): table<string, string>), autocmds: table, keymaps: table | (fun(config:config):any), wk: (fun(config: config):any) | table, legacy_setup: table, setup: table | (fun(config: config): any), on_setup: (fun(config: config): nil), on_done: (fun(config: config): nil) }
function M.define_extension(extension_name, active, config)
  vim.validate {
    active = { active, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
    on_init = { config.on_init, "f", true },
    condition = { config.condition, "f", true },
    packer = { config.packer, "f", true },
    to_inject = { config.to_inject, "f", true },
    autocmds = { config.autocmds, "t", true },
    keymaps = { config.keymaps, { "t", "f" }, true },
    wk = { config.wk, { "t", "f" }, true },
    legacy_setup = { config.legacy_setup, "t", true },
    setup = { config.legacy_setup, { "t", "f" }, true },
    on_setup = { config.on_setup, "f", true },
  }

  lvim.extensions[extension_name] = {
    name = extension_name,
    active = active,
    inject = {},
    store = {},
    set_injected = function(key, value)
      lvim.extensions[extension_name].inject[key] = value

      return value
    end,
    set_store = function(key, value)
      lvim.extensions[extension_name].store[key] = value

      return value
    end,
  }

  if config ~= nil and config.condition ~= nil and config.condition(lvim.extensions[extension_name]) == false then
    if config ~= nil and config.packer ~= nil then
      lvim.extensions[extension_name].packer = config.packer(lvim.extensions[extension_name])
    end

    Log:debug(string.format("Extension config stopped due to failed condition: %s", extension_name))

    return
  end

  if config ~= nil and config.on_init ~= nil then
    config.on_init(lvim.extensions[extension_name])
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], config or {})

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
---@param config config
function M.run(config)
  if config ~= nil and config.to_inject ~= nil then
    local ok = pcall(function()
      ---@diagnostic disable-next-line: assign-type-mismatch
      config.inject = vim.tbl_extend("force", config.inject, config.to_inject(config))
    end)

    if not ok then
      Log:debug(string.format("Can not inject in extension: %s", config.name))

      return
    end
  end

  if config ~= nil and config.autocmds ~= nil then
    M.define_autocmds(config.autocmds)
  end

  if config ~= nil and config.keymaps ~= nil then
    if type(config.keymaps) == "function" then
      M.load_mappings(config.keymaps(config))
    else
      ---@diagnostic disable-next-line: param-type-mismatch
      M.load_mappings(config.keymaps)
    end
  end

  if config ~= nil and config.wk ~= nil then
    if type(config.wk) == "function" then
      M.load_wk_mappings(config.wk(config))
    else
      M.load_wk_mappings(config.wk)
    end
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

  if config ~= nil and config.on_done ~= nil then
    config.on_done(config)
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
    if extension.packer ~= nil and type(extension.packer) == "table" then
      table.insert(packer, extension.packer)
    end
  end

  lvim.plugins = packer
end

return M
