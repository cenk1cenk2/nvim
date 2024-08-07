local Log = require("lvim.core.log")
local M = { fn = {} }

function M.load_wk(mappings)
  if not package_is_loaded("which-key") then
    lvim.wk = vim.list_extend(lvim.wk, mappings)

    return
  end

  require("which-key").add(mappings)
end

---
---@param mappings table
function M.load_mappings(mappings, opts)
  opts = opts or {}

  for _, mapping in pairs(mappings) do
    local m = vim.tbl_extend("force", { silent = true }, mapping)
    local lhs = table.remove(m, 1)
    local rhs = table.remove(m, 1)
    local mode = m.mode
    m.mode = nil
    m = vim.tbl_extend("force", m, opts)

    local ok, result = pcall(vim.keymap.set, mode, lhs, rhs, m)

    if not ok then
      Log:error(("Can not map keybind: %s > %s"):format(result, vim.inspect(mapping)))
    end
  end
end

function M.create_commands(collection)
  for _, cmd in pairs(collection) do
    local opts = vim.tbl_deep_extend("force", { force = true }, cmd.opts or {})
    vim.api.nvim_create_user_command(cmd.name, cmd.fn, opts)
  end
end

function M.set_option(arr)
  for k, v in pairs(arr) do
    vim.o[k] = v
  end
end

---
---@param opts table
function M.legacy_setup(opts)
  for opt, val in pairs(opts) do
    vim.g[opt] = val
  end
end

local function define_manager_plugin(config, plugin)
  if plugin.init ~= false and type(plugin.init) ~= "function" then
    Log:trace(string.format("Defining default init command for plugin: %s", config.name))

    plugin.init = function()
      require("utils.setup").plugin_init(config.name)
    end
  end

  if plugin.config ~= false and type(plugin.config) ~= "function" then
    Log:trace(string.format("Defining default config command for plugin: %s", config.name))

    plugin.config = function()
      require("utils.setup").plugin_configure(config.name)
    end
  end

  if plugin.enabled == nil then
    plugin.enabled = config.enabled
  end

  return plugin
end

---@alias fn { add_disabled_filetypes: (fun(ft: table<string>): nil), is_extension_enabled: (fun(extension: string): boolean), get_current_setup_wrapper: (fun(extension: string): (fun(): table)), get_current_setup: (fun(extension:string): table), append_to_setup: (fun(extension:string): table | (fun(config: config): table)) }
---@alias config table

---
---@param extension_name string
---@param enabled boolean
---@param config config
function M.define_extension(extension_name, enabled, config)
  vim.validate({
    enabled = { enabled, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
    on_init = { config.on_init, "f", true },
    plugin = { config.plugin, "f", true },
    autocmds = { config.autocmds, { "t", "f" }, true },
    keymaps = { config.keymaps, { "t", "f" }, true },
    wk = { config.wk, { "t", "f" }, true },
    legacy_setup = { config.legacy_setup, { "t", "f" }, true },
    setup = { config.setup, { "t", "f" }, true },
    extended_setup = { config.extended_setup, { "t", "f" }, true },
    on_setup = { config.on_setup, "f", true },
    hl = { config.hl, { "f", "t" }, true },
    signs = { config.signs, { "f", "t" }, true },
    on_complete = { config.on_complete, "f", true },
  })

  config = vim.tbl_extend("force", config, {
    name = extension_name,
    enabled = enabled,
    store = {},
    to_setup = {},
  }, lvim.extensions[extension_name] or {})

  if config ~= nil and config.plugin ~= nil then
    local plugins = {}

    local extension = config.plugin(config)

    if config.opts ~= nil and config.opts.multiple_packages then
      for _, e in pairs(extension) do
        table.insert(plugins, define_manager_plugin(config, e))
      end
    else
      table.insert(plugins, define_manager_plugin(config, extension))
    end

    config.extensions = plugins
  end

  if config ~= nil and config.condition ~= nil and config.condition(lvim.extensions[extension_name]) == false then
    lvim.extensions[extension_name] = config

    Log:debug(string.format("Extension config stopped due to failed condition: %s", extension_name))

    return
  end

  if config ~= nil and config.configure ~= nil then
    config.configure(config, M.fn)

    config.configure = nil
  end

  lvim.extensions[extension_name] = config
end

---@param definitions table contains a tuple of event, opts, see `:h nvim_create_autocmd`
function M.define_autocmds(definitions)
  for _, entry in ipairs(definitions) do
    if type(entry.group) == "string" and entry.group ~= "" then
      local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = entry.group })
      if not exists then
        vim.api.nvim_create_augroup(entry.group, {})
      end
    end
    local opts = vim.deepcopy(entry)
    opts.event = nil
    vim.api.nvim_create_autocmd(entry.event, opts)
  end
end

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
  -- defer the function in case the autocommand is still in-use
  Log:trace("request to clear autocmds  " .. name)
  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds({ group = name })
    end)
  end)
end

---
---@param extension_name string
---@return table
function M.get_config(extension_name)
  return lvim.extensions[extension_name]
end

---
---@param extension_name string
function M.plugin_init(extension_name)
  return M.init(M.get_config(extension_name))
end

---
---@param extension_name string
function M.plugin_configure(extension_name)
  return M.configure(M.get_config(extension_name))
end

---
---@param property function | table
---@return table
function M.evaluate_property(property, ...)
  if type(property) == "function" then
    return property(...)
  end

  return property
end

---
---@param config config
function M.init(config)
  if config ~= nil and config.on_init ~= nil then
    config.on_init(config)

    config.on_init = nil
  end

  if config ~= nil and config.autocmds ~= nil then
    M.define_autocmds(M.evaluate_property(config.autocmds, config, M.fn))

    config.autocmds = nil
  end

  if config ~= nil and config.keymaps ~= nil then
    M.load_mappings(M.evaluate_property(config.keymaps, config))

    config.keymaps = nil
  end

  if config ~= nil and config.wk ~= nil then
    M.load_wk(M.evaluate_property(config.wk, config, require("keys.wk").CATEGORIES, M.fn))

    config.wk = nil
  end

  if config ~= nil and config.hl ~= nil then
    local highlights = M.evaluate_property(config.hl, config, M.fn)

    for key, value in pairs(highlights) do
      vim.api.nvim_set_hl(0, key, value)
    end

    config.hl = nil
  end

  if config ~= nil and config.signs ~= nil then
    local signs = M.evaluate_property(config.signs, config)

    for key, value in pairs(signs) do
      -- this should be removed at some point since deprecated
      vim.fn.sign_define(key, value)
    end

    config.signs = nil
  end

  if config ~= nil and config.commands ~= nil then
    M.create_commands(M.evaluate_property(config.commands, config))

    config.commands = nil
  end

  if config ~= nil and config.nvim_opts ~= nil then
    M.set_option(config.nvim_opts)

    config.nvim_opts = nil
  end

  if config ~= nil and config.define_global_fn ~= nil then
    local functions = config.define_global_fn(config)

    for key, value in pairs(functions) do
      lvim.fn[key] = value
    end

    config.define_global_fn = nil
  end

  if config ~= nil and config.legacy_setup ~= nil then
    M.legacy_setup(M.evaluate_property(config.legacy_setup, config))

    config.legacy_setup = nil
  end
end

---
---@param config config
function M.configure(config)
  if config ~= nil and config.setup ~= nil then
    config.setup = M.evaluate_property(config.setup, config, M.fn)

    if config.to_setup ~= nil then
      for _, to_setup in pairs(config.to_setup) do
        config.setup = vim.tbl_deep_extend("force", config.setup, M.evaluate_property(to_setup, config, M.fn))
      end
    end

    lvim.extensions[config.name].current_setup = vim.deepcopy(config.setup)
  end

  if config ~= nil and config.extended_setup ~= nil then
    config.extended_setup = M.evaluate_property(config.extended_setup, config, M.fn)

    lvim.extensions[config.name].current_extended_setup = vim.deepcopy(config.extended_setup)
  end

  if config ~= nil and config.on_setup ~= nil then
    config.on_setup(config, M.fn)

    config.on_setup = nil
  end

  if config ~= nil and config.on_done ~= nil then
    config.on_done(config, M.fn)

    config.on_done = nil
  end

  if config ~= nil and config.on_complete ~= nil then
    config.on_complete(config, M.fn)

    config.on_complete = nil
  end

  config.setup = nil
  config.extended_setup = nil
end

function M.set_plugins()
  local plugins = {}

  for _, extension in pairs(lvim.extensions) do
    if extension.extensions ~= nil then
      for _, e in pairs(extension.extensions) do
        table.insert(plugins, e)
      end
    end
  end

  lvim.plugins = plugins
end

-- fn functions

---@param ft table<string>
function M.fn.add_disabled_filetypes(ft)
  for _, value in pairs(ft) do
    table.insert(lvim.disabled_filetypes, value)
  end
end

---@param extension string
function M.fn.is_extension_enabled(extension)
  return (M.get_config(extension) or {}).enabled
end

function M.fn.append_to_setup(extension_name, to_setup)
  if lvim.extensions[extension_name] == nil then
    lvim.extensions[extension_name] = {
      to_setup = {},
    }
  end

  table.insert(lvim.extensions[extension_name].to_setup, to_setup)
end

function M.fn.get_wk_categories()
  return require("keys.wk").CATEGORIES
end

function M.fn.get_wk_category(category)
  return M.fn.get_wk_categories()[category]
end

function M.fn.get_current_setup_wrapper(extension_name)
  return function()
    return M.fn.get_current_setup(extension_name)
  end
end

function M.fn.get_current_setup(extension_name)
  return lvim.extensions[extension_name].current_setup
end

function M.fn.get_highlight(name)
  return vim.api.nvim_get_hl(0, { name = name })
end

function M.fn.add_global_function(name, fn)
  lvim.fn[name] = fn

  return fn
end

--- Builds a WK mapping location with leader.
---@param keystrokes table
---@return string
function M.fn.keystroke(keystrokes)
  return table.concat(keystrokes, "")
end

--- Builds a WK mapping location with leader.
---@param keystrokes table
---@return string
function M.fn.wk_keystroke(keystrokes)
  return M.fn.keystroke(vim.list_extend({ "<Leader>" }, keystrokes))
end

return M
