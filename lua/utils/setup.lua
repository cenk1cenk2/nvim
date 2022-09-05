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
    local modes = table.remove(mapping, 1)

    for _, mode in pairs(modes) do
      keymappings.load_mode(mode, { [key] = mapping })
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
---@param config table
function M.on_setup_done(config)
  if config.on_config_done then
    config.on_config_done()
  end
end

---
---@param extension_name string
---@param active boolean
---@param config table
---@param opts? table
function M.define_extension(extension_name, active, config, opts)
  vim.validate {
    active = { active, "b" },
    extension_name = { extension_name, "s" },
    config = { config, "t" },
  }

  lvim.extensions[extension_name] = {
    active = active,
  }

  if opts ~= nil and opts.condition and not opts.condition() then
    Log:debug(string.format("Extension config stopped due to failed condition: %s", extension_name))

    return
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], config)
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

return M
