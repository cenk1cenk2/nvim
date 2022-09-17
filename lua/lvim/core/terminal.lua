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
  local editor = "nvr --servername " .. vim.v.servername .. " -cc split --remote-wait +'set bufhidden=wipe'"

  if vim.fn.has "nvim" and vim.fn.executable "nvr" then
    vim.env.GIT_EDITOR = editor
    vim.env.VISUAL = editor
    vim.env.EDITOR = editor
    vim.env.NVIM_LISTEN_ADDRESS = vim.v.servername
  end

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
      ["<F1>"] = function()
        M.current_float_terminal():toggle()
      end,
      ["<F2>"] = function()
        M.float_terminal_select "prev"
      end,
      ["<F3>"] = function()
        M.float_terminal_select "next"
      end,
      ["<F4>"] = function()
        M.create_and_open_float_terminal()
      end,
      ["<F6>"] = function()
        M.buffer_terminal()
      end,
      ["<F7>"] = function()
        M.bottom_terminal()
      end,
      ["<F9>"] = function()
        M.terminal_kill_all()
      end,
      ["<F11>"] = ":Mason<CR>",
    },
    term_mode = {
      ["<F1>"] = function()
        M.current_float_terminal():toggle()
      end,
      ["<F2>"] = function()
        M.float_terminal_select "prev"
      end,
      ["<F3>"] = function()
        M.float_terminal_select "next"
      end,
      ["<F4>"] = function()
        M.create_and_open_float_terminal()
      end,
      ["<F6>"] = function()
        M.buffer_terminal()
      end,
      ["<F7>"] = function()
        M.bottom_terminal()
      end,
      ["<F9>"] = function()
        M.terminal_kill_all()
      end,
    },
  }

  lvim.builtin.which_key.mappings["t"]["b"] = {
    function()
      M.buffer_terminal()
    end,
    "buffer cwd terminal",
  }

  lvim.builtin.which_key.mappings["t"]["B"] = {
    function()
      M.bottom_terminal()
    end,
    "bottom terminal",
  }

  lvim.builtin.which_key.mappings["t"]["X"] = {
    function()
      M.terminal_kill_all()
    end,
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

  lvim.builtin.which_key.mappings[opts.keymap] = {
    exec_func,
    opts.label,
  }

  local wk_status_ok, wk = pcall(require, "which-key")
  if not wk_status_ok then
    return
  end
  wk.register({ [opts.keymap] = { opts.label } }, { mode = "n" })
end

local terminals = {}

M._on_open = function(term)
  vim.api.nvim_set_current_win(term.window)
  vim.cmd "startinsert!"
end

M._exec_toggle = function(exec)
  if not terminals[exec.cmd] then
    local Terminal = require("toggleterm.terminal").Terminal

    terminals[exec.cmd] = Terminal:new {
      cmd = exec.cmd,
      hidden = true,
      on_open = M._on_open,
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
    index = vim.tbl_count(float_terminals) + 1
  end

  Log:debug("Terminal created: " .. index)

  table.insert(
    float_terminals,
    index,
    Terminal:new {
      cmd = vim.o.shell,
      direction = "float",
      hidden = true,
      on_open = M._on_open,
      on_exit = function(terminal)
        for i, t in pairs(float_terminals) do
          if t.id == terminal.id then
            table.remove(float_terminals, i)
          end
        end

        if float_terminal_current > vim.tbl_count(float_terminals) then
          float_terminal_current = vim.tbl_count(float_terminals)
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

    if updated > vim.tbl_count(float_terminals) then
      float_terminal_current = 1
    else
      float_terminal_current = updated
    end
  elseif action == "prev" then
    local updated = float_terminal_current - 1

    if updated < 1 then
      float_terminal_current = vim.tbl_count(float_terminals)
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
      on_open = M._on_open,
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
  Log:debug("attempting to open: " .. logfile)
  log_viewer = log_viewer .. " " .. logfile
  local term_opts = vim.tbl_deep_extend("force", lvim.builtin.terminal, {
    cmd = log_viewer,
    -- Open_mapping = lvim.log.viewer.layout_config.open_mapping,
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
