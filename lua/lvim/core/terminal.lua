local M = {}
local Log = require "lvim.core.log"

M.config = function()
  lvim.builtin["terminal"] = {
    active = true,
    on_config_done = nil,
    -- size can be a number or function which is passed the current terminal
    size = 20,
    -- open_mapping = [[<c-\>]],
    open_mapping = [[<F12>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = false,
    -- direction = 'vertical' | 'horizontal' | 'window' | 'float',
    direction = "float",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      -- The border key is *almost* the same as 'nvim_win_open'
      -- see :h nvim_win_open for details on borders however
      -- the 'curved' border is a custom border type
      -- not natively supported but implemented in this plugin.
      -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
      border = "curved",
      -- width = <value>,
      -- height = <value>,
      winblend = 0,
      highlights = { border = "Normal", background = "Normal" },
    },
    -- Add executables on the config.lua
    -- { exec, keymap, name}
    -- lvim.builtin.terminal.execs = {{}} to overwrite
    -- lvim.builtin.terminal.execs[#lvim.builtin.terminal.execs+1] = {"gdb", "tg", "GNU Debugger"}
    execs = {
      { "lazygit", "tg", "LazyGit" },
      { "lazydocker", "td", "LazyDocker" },
      { "htop", "th", "htop" },
      { "ncdu", "tn", "ncdu" },
    },
  }
end

M.setup = function()
  local terminal = require "toggleterm"
  for _, exec in pairs(lvim.builtin.terminal.execs) do
    require("lvim.core.terminal").add_exec(exec[1], exec[2], exec[3])
  end
  terminal.setup(lvim.builtin.terminal)

  if lvim.builtin.terminal.on_config_done then
    lvim.builtin.terminal.on_config_done(terminal)
  end

  require("lvim.keymappings").load {
    normal_mode = {
      ["<F1>"] = ":lua require('lvim.core.terminal').float_terminal()<CR>",
      ["<F2>"] = ":lua require('lvim.core.terminal')._exec_toggle('lazygit')<CR>",
      ["<F3>"] = ":lua require('lvim.core.terminal')._exec_toggle('lazydocker')<CR>",
      ["<F4>"] = ":lua require('lvim.core.terminal').bottom_terminal()<CR>",
      ["<F6>"] = ":lua require('lvim.core.terminal').buffer_terminal()<CR>",
      ["<F7>"] = ":lua require('lvim.core.terminal').buffer_terminal_kill_all()<CR>",
      ["<F11>"] = ":LspInstallInfo<CR>",
    },
    term_mode = {
      ["<F1>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').close_all(true)<CR>",
      ["<F2>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').close_all()<CR>",
      ["<F3>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').close_all()<CR>",
      ["<F4>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').close_all()<CR>",
      ["<F6>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').close_all()<CR>",
      ["<F7>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').buffer_terminal_kill_all()<CR>",
      -- ["<F1>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').float_terminal()<CR>",
      -- ["<F2>"] = "<C-\\><C-n>:lua require('lvim.core.terminal')._exec_toggle('lazygit')<CR>",
      -- ["<F3>"] = "<C-\\><C-n>:lua require('lvim.core.terminal')._exec_toggle('lazydocker')<CR>",
      -- ["<F4>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').bottom_terminal()<CR>",
    },
  }
end

M.add_exec = function(exec, keymap, name)
  vim.api.nvim_set_keymap(
    "n",
    "<leader>" .. keymap,
    "<cmd>lua require('lvim.core.terminal')._exec_toggle('" .. exec .. "')<CR>",
    { noremap = true, silent = true }
  )
  lvim.builtin.which_key.mappings[keymap] = name
end

M._split = function(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local terminals = {}

M._exec_toggle = function(exec)
  if not terminals[exec] then
    local Terminal = require("toggleterm.terminal").Terminal

    local binary = M._split(exec)[1]
    if vim.fn.executable(binary) ~= 1 then
      Log:error("Unable to run executable " .. binary .. ". Please make sure it is installed properly.")
      return
    end

    terminals[exec] = Terminal:new {
      cmd = exec,
      hidden = true,
    }
  end

  terminals[exec]:toggle()

  return terminals[exec]
end

M.float_terminal = function()
  if not terminals["float"] then
    local Terminal = require("toggleterm.terminal").Terminal
    terminals["float"] = Terminal:new {
      cmd = vim.o.shell,
      direction = "float",
      hidden = true,
    }
  end

  terminals["float"]:toggle()

  return terminals["float"]
end

M.bottom_terminal = function()
  if not terminals["bottom"] then
    local Terminal = require("toggleterm.terminal").Terminal
    terminals["bottom"] = Terminal:new {
      cmd = vim.o.shell,
      direction = "horizontal",
      hidden = true,
    }
  end

  terminals["bottom"]:toggle()

  return terminals["bottom"]
end

M.buffer_terminal = function()
  local current = vim.fn.expand "%:p:h"

  if not terminals[current] then
    local Terminal = require("toggleterm.terminal").Terminal
    terminals[current] = Terminal:new {
      cmd = vim.o.shell,
      dir = current,
      direction = "float",
      hidden = true,
    }

    terminals[current].is_buffer_terminal = true
  end

  terminals[current]:toggle()

  return terminals[current]
end

M.buffer_terminal_kill_all = function()
  for terminal in pairs(terminals) do
    if terminal.is_buffer_terminal and terminal:is_open() then
      terminal:shutdown()
    end
  end
end

M.close_all = function(open_default_after)
  local terms = require "toggleterm.terminal"
  local all_terminals = vim.tbl_extend("force", terms.get_all(), terminals)
  local is_closing_default = false

  for key, terminal in pairs(all_terminals) do
    if terminal:is_open() then
      terminal:close()

      if key ~= "float" then
        is_closing_default = true
      end
    end
  end

  if open_default_after and is_closing_default then
    M.float_terminal()
  end
end

---Toggles a log viewer according to log.viewer.layout_config
---@param logfile string the fullpath to the logfile
M.toggle_log_view = function(logfile)
  local log_viewer = lvim.log.viewer.cmd
  if vim.fn.executable(log_viewer) ~= 1 then
    log_viewer = "less +F"
  end
  log_viewer = log_viewer .. " " .. logfile
  local term_opts = vim.tbl_deep_extend("force", lvim.builtin.terminal, {
    cmd = log_viewer,
    -- open_mapping = lvim.log.viewer.layout_config.open_mapping,
    direction = lvim.log.viewer.layout_config.direction,
    -- TODO: this might not be working as expected
    size = lvim.log.viewer.layout_config.size,
    float_opts = lvim.log.viewer.layout_config.float_opts,
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

return M
