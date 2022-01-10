local M = {}
local Log = require "lvim.core.log"
local table_utils = require "lvim.utils.table"

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
      border = "single",
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
  terminal.setup(lvim.builtin.terminal)

  for i, exec in pairs(lvim.builtin.terminal.execs) do
    local opts = {
      cmd = exec[1],
      keymap = exec[2],
      label = exec[3],
      -- NOTE: unable to consistently bind id/count <= 9, see #2146
      count = i + 100,
      direction = exec[4] or lvim.builtin.terminal.direction,
      size = lvim.builtin.terminal.size,
    }

    M.add_exec(opts)
  end

  if lvim.builtin.terminal.on_config_done then
    lvim.builtin.terminal.on_config_done(terminal)
  end

  require("lvim.keymappings").load {
    normal_mode = {
      ["<F1>"] = ":lua require('lvim.core.terminal').current_float_terminal():toggle()<CR>",
      ["<F2>"] = ":lua require('lvim.core.terminal').float_terminal_select('prev')<CR>",
      ["<F3>"] = ":lua require('lvim.core.terminal').float_terminal_select('next')<CR>",
      ["<F4>"] = ":lua require('lvim.core.terminal').create_and_open_float_terminal()<CR>",
      ["<F6>"] = ":lua require('lvim.core.terminal').buffer_terminal()<CR>",
      ["<F7>"] = ":lua require('lvim.core.terminal').bottom_terminal()<CR>",
      ["<F9>"] = ":lua require('lvim.core.terminal').terminal_kill_all()<CR>",
      ["<F11>"] = ":LspInstallInfo<CR>",
    },
    term_mode = {
      ["<F1>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').close_all()<CR>",
      ["<F2>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').float_terminal_select('prev')<CR>",
      ["<F3>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').float_terminal_select('next')<CR>",
      ["<F4>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').create_float_terminal()<CR>",
      ["<F9>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').terminal_kill_all()<CR>",
      -- ["<F1>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').float_terminal()<CR>",
      -- ["<F2>"] = "<C-\\><C-n>:lua require('lvim.core.terminal')._exec_toggle('lazygit')<CR>",
      -- ["<F3>"] = "<C-\\><C-n>:lua require('lvim.core.terminal')._exec_toggle('lazydocker')<CR>",
      -- ["<F4>"] = "<C-\\><C-n>:lua require('lvim.core.terminal').bottom_terminal()<CR>",
    },
  }

  lvim.builtin.which_key.mappings["t"]["b"] = {
    ":lua require('lvim.core.terminal').buffer_terminal()<CR>",
    "buffer cwd terminal",
  }

  lvim.builtin.which_key.mappings["t"]["B"] = {
    ":lua require('lvim.core.terminal').bottom_terminal()<CR>",
    "bottom terminal",
  }

  lvim.builtin.which_key.mappings["t"]["X"] = {
    ":lua require('lvim.core.terminal').terminal_kill_all()<CR>",
    "kill all terminals",
  }
end

M.add_exec = function(opts)
  local binary = opts.cmd:match "(%S+)"
  if vim.fn.executable(binary) ~= 1 then
    Log:debug("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
    return
  end

  local exec_func = string.format(
    "<cmd>lua require('lvim.core.terminal')._exec_toggle({ cmd = '%s', count = %d, direction = '%s'})<CR>",
    opts.cmd,
    opts.count,
    opts.direction
  )

  require("lvim.keymappings").load {
    normal_mode = { [opts.keymap] = exec_func },
    term_mode = { [opts.keymap] = exec_func },
  }

  lvim.builtin.which_key.mappings[opts.keymap] = opts.label
end

local terminals = {}

M._exec_toggle = function(exec)
  if not terminals[exec.cmd] then
    local Terminal = require("toggleterm.terminal").Terminal

    terminals[exec.cmd] = Terminal:new {
      cmd = exec.cmd,
      hidden = true,
    }
  end

  terminals[exec.cmd]:toggle()

  return terminals[exec.cmd]
end

local float_terminals = {}
local float_terminal_current = 1

M.current_float_terminal = function()
  if not float_terminals[float_terminal_current] then
    float_terminal_current = 1
  end

  if vim.tbl_isempty(float_terminals) then
    M.create_float_terminal(float_terminal_current)
  end

  Log:debug("Terminal switched: " .. float_terminal_current)

  return float_terminals[float_terminal_current]
end

M.create_float_terminal = function(index)
  local Terminal = require("toggleterm.terminal").Terminal

  if not index then
    index = table_utils.length(float_terminals) + 1
  end

  Log:debug("Terminal created: " .. index)

  table.insert(
    float_terminals,
    index,
    Terminal:new {
      cmd = vim.o.shell,
      direction = "float",
      hidden = true,
      on_exit = function(terminal)
        for i, t in pairs(float_terminals) do
          if t.id == terminal.id then
            table.remove(float_terminals, i)
          end
        end

        if float_terminal_current > table_utils.length(float_terminals) then
          float_terminal_current = table_utils.length(float_terminals)
        elseif float_terminal_current < index then
          float_terminal_current = float_terminal_current - 1
        end
      end,
    }
  )

  float_terminal_current = index

  return float_terminals[index]
end

M.create_and_open_float_terminal = function()
  if not vim.tbl_isempty(float_terminals) and M.current_float_terminal():is_open() then
    M.current_float_terminal():close()
  end

  M.create_float_terminal()

  M.current_float_terminal():open()
end

M.float_terminal_select = function(action)
  if M.current_float_terminal():is_open() then
    M.current_float_terminal():close()
  end

  if vim.tbl_isempty(float_terminals) then
    M.create_float_terminal()
  elseif action == "next" then
    local updated = float_terminal_current + 1

    if updated > table_utils.length(float_terminals) then
      float_terminal_current = 1
    else
      float_terminal_current = updated
    end
  elseif action == "prev" then
    local updated = float_terminal_current - 1

    if updated < 1 then
      float_terminal_current = table_utils.length(float_terminals)
    else
      float_terminal_current = updated
    end
  end

  M.current_float_terminal():open()
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

  local t = M.create_float_terminal()

  t:toggle()

  if t.dir ~= current then
    t:change_dir(current)
  end

  return t
end

M.terminal_kill_all = function()
  local terms = require "toggleterm.terminal"
  local all_terminals = vim.tbl_extend("force", terms.get_all(), terminals, float_terminals)

  for _, terminal in pairs(all_terminals) do
    terminal:shutdown()
  end

  float_terminals = {}
  float_terminal_current = 0
end

M.close_all = function()
  local terms = require "toggleterm.terminal"
  local all_terminals = vim.tbl_extend("force", terms.get_all(), terminals, float_terminals)

  for _, terminal in pairs(all_terminals) do
    if terminal:is_open() then
      terminal:close()
    end
  end

  vim.cmd [[
    let win_hd = rnvimr#context#winid()
    if rnvimr#context#bufnr() != -1
        if win_hd != -1 && nvim_win_is_valid(win_hd)
            if nvim_get_current_win() == win_hd
                call nvim_win_close(win_hd, 0)
                call rnvimr#rpc#clear_image()
            endif
        endif
    endif
  ]]
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
