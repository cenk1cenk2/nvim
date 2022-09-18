local Log = require "lvim.core.log"
local M = {}

local keymappings = require "lvim.keymappings"
---
---@param mappings table
function M.load_wk_mappings(mappings)
  for key, value in pairs(mappings) do
    lvim.wk.mappings[key] = vim.tbl_deep_extend("force", lvim.wk.mappings[key] or {}, value)
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

---@alias config { name: string, opts: { multiple_packages: boolean }, on_init: (fun(config: config): nil), configure: (fun(config: config): nil),condition: (fun(config: config): boolean | nil), packer: (fun(config: config): table), to_inject: (fun(config: config): table<string, string>), autocmds: table| (fun(config: config): nil), keymaps: table | (fun(config: config): any), wk: (fun(config: config):any) | table, legacy_setup: table, setup: table | (fun(config: config): any), on_setup: (fun(config: config): nil), on_done: (fun(config: config): nil), commands: table | (fun(config: config): any), nvim_opts: table, hl: (fun(config: config): table) | table, signs: (fun(config: config): table) | table, on_complete: (fun(config: config): table), to_setup: table, current_setup: table, define_global_fn: (fun(config: config): table<string, string>) }

---
---@param extension_name string
---@param active boolean
---@param config config
function M.define_extension(extension_name, active, config)
  vim.validate {
    active = { active, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
    on_init = { config.on_init, "f", true },
    condition = { config.condition, "f", true },
    packer = { config.packer, "f", true },
    to_inject = { config.to_inject, "f", true },
    autocmds = { config.autocmds, { "t", "f" }, true },
    keymaps = { config.keymaps, { "t", "f" }, true },
    wk = { config.wk, { "t", "f" }, true },
    legacy_setup = { config.legacy_setup, "t", true },
    setup = { config.legacy_setup, { "t", "f" }, true },
    on_setup = { config.on_setup, "f", true },
    hl = { config.hl, { "f", "t" }, true },
    signs = { config.signs, { "f", "t" }, true },
    on_complete = { config.on_complete, "f", true },
  }

  lvim.extensions[extension_name] = {
    name = extension_name,
    active = active,
    inject = {},
    store = {},
    to_setup = {},
    set_injected = function(key, value)
      lvim.extensions[extension_name].inject[key] = value

      return value
    end,
    get_injected = function(key)
      return lvim.extensions[extension_name].inject[key]
    end,
    set_store = function(key, value)
      lvim.extensions[extension_name].store[key] = value

      return value
    end,
    get_store = function(key)
      return lvim.extensions[extension_name].store[key]
    end,
  }

  if config ~= nil and config.condition ~= nil and config.condition(lvim.extensions[extension_name]) == false then
    if config ~= nil and config.packer ~= nil then
      lvim.extensions[extension_name].packer = config.packer(lvim.extensions[extension_name])
    end

    Log:debug(string.format("Extension config stopped due to failed condition: %s", extension_name))

    return
  end

  if config ~= nil and config.configure ~= nil then
    config.configure(config)
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
---@param property string
---@return table
function M.as_function_or_table(config, property)
  if type(config[property]) == "function" then
    return config[property](config)
  end

  return config[property]
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
      Log:warn(string.format("Can not inject in extension: %s", config.name))

      return
    end
  end

  if config ~= nil and config.on_init ~= nil then
    config.on_init(config)
  end

  if config ~= nil and config.autocmds ~= nil then
    M.define_autocmds(M.as_function_or_table(config, "autocmds"))
  end

  if config ~= nil and config.keymaps ~= nil then
    M.load_mappings(M.as_function_or_table(config, "keymaps"))
  end

  if config ~= nil and config.wk ~= nil then
    M.load_wk_mappings(M.as_function_or_table(config, "wk"))
  end

  if config ~= nil and config.hl ~= nil then
    local highlights = M.as_function_or_table(config, "hl")

    for key, value in pairs(highlights) do
      vim.api.nvim_set_hl(0, key, value)
    end
  end

  if config ~= nil and config.signs ~= nil and lvim.use_icons then
    local signs = M.as_function_or_table(config, "signs")

    for key, value in pairs(signs) do
      vim.fn.sign_define(key, value)
    end
  end

  if config ~= nil and config.commands ~= nil then
    require("utils.command").create_commands(M.as_function_or_table(config, "commands"))
  end

  if config ~= nil and config.nvim_opts ~= nil then
    require("utils.command").set_option(config.nvim_opts)
  end

  if config ~= nil and config.legacy_setup ~= nil then
    M.legacy_setup(config.legacy_setup)
  end

  if config ~= nil and config.setup ~= nil then
    config.setup = M.as_function_or_table(config, "setup")

    if config.to_setup ~= nil then
      config.setup = vim.tbl_deep_extend("force", config.setup, config.to_setup)
    end

    lvim.extensions[config.name].current_setup = vim.deepcopy(config.setup)
  end

  if config ~= nil and config.on_setup ~= nil then
    config.on_setup(config)
  end

  if config ~= nil and config.on_done ~= nil then
    config.on_done(config)
  end

  if config ~= nil and config.define_global_fn ~= nil then
    local functions = config.define_global_fn(config)

    for key, value in pairs(functions) do
      lvim.fn[key] = value
    end
  end

  if config ~= nil and config.on_complete ~= nil then
    config.on_complete(config)
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
      if extension.opts ~= nil and extension.opts.multiple_packages then
        for _, e in pairs(extension.packer) do
          table.insert(packer, e)
        end
      else
        table.insert(packer, extension.packer)
      end
    end
  end

  lvim.plugins = packer
end

function M.get_current_setup(extension_name)
  return function()
    return lvim.extensions[extension_name].current_setup
  end
end

return M
