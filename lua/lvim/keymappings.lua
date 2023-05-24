local M = {}

local Log = require("lvim.core.log")

local generic_opts_any = { noremap = true, silent = true }

M.opts = {
  i = generic_opts_any,
  n = generic_opts_any,
  v = generic_opts_any,
  x = generic_opts_any,
  c = generic_opts_any,
  t = { silent = true },
}

M.modes = {
  all = { "n", "v", "x" },
  a = { "n", "v", "x" },
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
  operator_pending_mode = "o",
  normal = "n",
  insert = "i",
  visual = "v",
  term = "t",
  visual_block = "x",
  command = "c",
  operator = "o",
  n = "n",
  i = "i",
  v = "v",
  t = "t",
  vb = "x",
  c = "c",
  o = "o",
}

-- Unset all keybindings defined in keymaps
-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.clear(keymaps)
  local default = M.get_defaults()
  for mode, mappings in pairs(keymaps) do
    local translated_mode = M.modes[mode] or mode
    for key, _ in pairs(mappings) do
      -- some plugins may override default bindings that the user hasn't manually overridden
      if default[mode][key] ~= nil or (default[translated_mode] ~= nil and default[translated_mode][key] ~= nil) then
        pcall(vim.keymap.del, translated_mode, key)
      end
    end
  end
end

-- Set key mappings individually
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = M.opts[mode]

  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end

  if val then
    vim.keymap.set(mode, key, val, opt)
  else
    pcall(vim.api.nvim_del_keymap, mode, key)
  end
end

-- Load key mappings for a given mode
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(modes, keymaps)
  if type(modes) == "string" then
    modes = { modes }
  end

  for _, mode in pairs(modes) do
    mode = M.modes[mode] or mode

    for k, v in pairs(keymaps) do
      M.set_keymaps(mode, k, v)
    end
  end
end

-- Load key mappings for all provided modes
-- @param keymaps A list of key mappings for each mode
function M.load(keymaps)
  keymaps = keymaps or {}

  if vim.tbl_islist(keymaps) then
    for _, map in pairs(keymaps) do
      local mode = map[1]
      table.remove(map, 1)

      M.load_mode(mode, map)
    end

    return
  end

  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

-- Load the default keymappings
function M.load_defaults()
  lvim.keys = require("keys.default")

  return lvim.keys
end

function M.setup()
  vim.g.mapleader = (lvim.leader == "space" and " ") or lvim.leader
  Log:debug("Initialized keybindings.")
  M.load(lvim.keys)
end

return M
