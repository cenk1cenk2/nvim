-- https://github.com/akinsho/toggleterm.nvim
local M = {}

local extension_name = "toggleterm_nvim"

local Log = require "lvim.core.log"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "akinsho/toggleterm.nvim",
        event = "BufWinEnter",
        config = function()
          require("utils.setup").packer_config "toggleterm_nvim"
        end,
        disable = not config.active,
      }
    end,
    configure = function()
      table.insert(lvim.disabled_filetypes, "toggleterm")
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
      }
    end,
    setup = {
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
      winbar = {
        enabled = false,
        name_formatter = function(terminal) --  term: Terminal
          return terminal.name
        end,
      },
      on_open = M.on_open,
      on_exit = M.on_exit,
    },
    togglers = {
      { cmd = "lazygit", keymap = "g", label = "LazyGit" },
      { cmd = "lazydocker", keymap = "d", label = "LazyDocker" },
      { cmd = "htop", keymap = "h", label = "htop" },
      { cmd = "ncdu", keymap = "n", label = "ncdu" },
    },
    on_setup = function(config)
      require("toggleterm").setup(config.setup)
    end,
    on_done = function(config)
      local editor = "nvr --servername " .. vim.v.servername .. " -cc split --remote-wait +'set bufhidden=wipe'"

      if vim.fn.has "nvim" and vim.fn.executable "nvr" then
        vim.env.GIT_EDITOR = editor
        vim.env.VISUAL = editor
        vim.env.EDITOR = editor
        vim.env.NVIM_LISTEN_ADDRESS = vim.v.servername
      end

      for i, exec in pairs(config.togglers) do
        local opts = {
          cmd = exec.cmd,
          keymap = exec.keymap,
          label = exec.label,
          -- NOTE: unable to consistently bind id/count <= 9, see #2146
          count = i + 100,
          direction = exec.direction or M.current_setup().direction,
          size = M.current_setup().size,
        }

        M.create_toggle_term(opts)
      end

      local telescope = config.inject.telescope
      telescope.load_extension "find_terminals"
    end,
    define_global_fn = function()
      return { toggle_log_view = M.toggle_log_view }
    end,
    keymaps = function()
      local maps = {
        ["<F1>"] = function()
          M.get_current_float_terminal():toggle()
        end,
        ["<F2>"] = function()
          M.float_terminal_select "prev"
        end,
        ["<F3>"] = function()
          M.float_terminal_select "next"
        end,
        ["<F4>"] = function()
          M.append_float_terminal()
        end,
        ["<F6>"] = function()
          M.create_buffer_terminal()
        end,
        ["<F7>"] = function()
          M.create_bottom_terminal()
        end,
        ["<F9>"] = function()
          M.kill_all()
        end,
      }

      return {
        n = maps,
        t = vim.tbl_extend("force", maps, {
          ["<F1>"] = function()
            M.close_all()
          end,
        }),
      }
    end,
    wk = {
      ["t"] = {
        f = { ":Telescope find_terminals list<CR>", "list terminals" },

        ["b"] = {
          function()
            M.create_buffer_terminal()
          end,
          "buffer cwd terminal",
        },

        ["B"] = {
          function()
            M.create_bottom_terminal()
          end,
          "bottom terminal",
        },

        ["X"] = {
          function()
            M.kill_all()
          end,
          "kill all terminals",
        },
      },
    },
    autocmds = {
      {
        { "TermOpen" },
        {
          group = "__TERMINAL",
          pattern = "*",
          command = "nnoremap <buffer><LeftRelease> <LeftRelease>i",
        },
      },
    },
  })
end

M.terminals = {}
M.float_terminals = {}
M.float_terminal_current = 0
M.marks = {
  MARK = "__marks",
  IS_INDEXED = "is_indexed",
  INDEX = "index",
  HAS_EXIT = "has_exit",
}

function M.on_open(terminal)
  terminal:focus()

  if not M.get_mark(terminal, M.marks.HAS_EXIT) then
    terminal:set_mode(require("toggleterm.terminal").mode.INSERT)
  end
end

function M.on_exit(terminal) end

function M.create_toggle_term(opts)
  local binary = opts.cmd:match "(%S+)"
  if vim.fn.executable(binary) ~= 1 then
    Log:debug("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
    return
  end

  require("utils.setup").load_wk_mappings {
    ["t"] = {
      [opts.keymap] = {
        function()
          M.toggle_toggle_term { cmd = opts.cmd, count = opts.count, direction = opts.direction }
        end,
        opts.label,
      },
    },
  }
end

function M.toggle_toggle_term(toggler)
  if not M.terminals[toggler.cmd] then
    local Terminal = require("toggleterm.terminal").Terminal

    M.terminals[toggler.cmd] = Terminal:new {
      cmd = toggler.cmd,
      hidden = true,
    }
  end

  M.terminals[toggler.cmd]:toggle()

  return M.terminals[toggler.cmd]
end

function M.get_current_float_terminal()
  if not M.float_terminals[M.float_terminal_current] then
    M.float_terminal_current = 1
  end

  local terminal
  if vim.tbl_isempty(M.float_terminals) then
    terminal = M.create_float_terminal()
  else
    terminal = M.float_terminals[M.float_terminal_current]
  end

  Log:debug("Terminal switched: " .. M.float_terminal_current)

  return terminal
end

function M.float_terminal_on_open(terminal)
  if M.get_mark(terminal, M.marks.IS_INDEXED) then
    return
  end

  M.set_mark(terminal, M.marks.IS_INDEXED, true)

  local index = vim.tbl_count(M.float_terminals) + 1

  Log:debug("Terminal created: " .. index)

  table.insert(M.float_terminals, index, terminal)
  M.set_mark(terminal, M.marks.INDEX, index)

  M.float_terminal_current = index

  M.on_open(terminal)
end

function M.float_terminal_on_exit(terminal)
  local cb = function()
    for i, t in pairs(M.float_terminals) do
      if t.id == terminal.id then
        table.remove(M.float_terminals, i)
      end
    end

    if M.float_terminal_current > vim.tbl_count(M.float_terminals) then
      M.float_terminal_current = vim.tbl_count(M.float_terminals)
    elseif M.float_terminal_current < M.get_mark(terminal, M.marks.INDEX) then
      M.float_terminal_current = M.float_terminal_current - 1
    end
  end

  M.set_mark(terminal, M.marks.HAS_EXIT, true)

  if terminal.close_on_exit then
    cb()
  else
    local keymap_cb = function()
      terminal:shutdown()
      cb()

      Log:debug("Shutdown current terminal manually: " .. terminal.cmd)
    end

    vim.keymap.set("n", "q", keymap_cb, { silent = true, buffer = terminal.bufnr })
    vim.keymap.set("i", "<CR>", keymap_cb, { silent = true, buffer = terminal.bufnr })
  end
end

function M.set_mark(terminal, key, value)
  if not terminal[M.marks.MARK] then
    terminal[M.marks.MARK] = {}
  end

  terminal[M.marks.MARK][key] = value

  return terminal
end

function M.get_mark(terminal, key)
  if not terminal[M.marks.MARK] then
    terminal[M.marks.MARK] = {}

    return nil
  end

  return terminal[M.marks.MARK][key]
end

function M.generate_defaults_float_terminal(opts)
  return vim.tbl_extend("force", opts or {}, {
    direction = "float",
    hidden = true,
    on_open = M.float_terminal_on_open,
    on_exit = M.float_terminal_on_exit,
  })
end

function M.create_float_terminal()
  local Terminal = require("toggleterm.terminal").Terminal

  local terminal = Terminal:new(M.generate_defaults_float_terminal {
    cmd = vim.o.shell,
  })

  return terminal
end

function M.append_float_terminal()
  if not vim.tbl_isempty(M.float_terminals) and M.get_current_float_terminal():is_open() then
    M.get_current_float_terminal():close()
  end

  local terminal = M.create_float_terminal()

  terminal:open()
end

function M.float_terminal_select(action)
  if M.get_current_float_terminal():is_open() then
    M.get_current_float_terminal():close()
  end

  if vim.tbl_isempty(M.float_terminals) then
    M.create_float_terminal()
  elseif action == "next" then
    local updated = M.float_terminal_current + 1

    if updated > vim.tbl_count(M.float_terminals) then
      M.float_terminal_current = 1
    else
      M.float_terminal_current = updated
    end
  elseif action == "prev" then
    local updated = M.float_terminal_current - 1

    if updated < 1 then
      M.float_terminal_current = vim.tbl_count(M.float_terminals)
    else
      M.float_terminal_current = updated
    end
  end

  local current = M.get_current_float_terminal()
  current:open()
  M.on_open(current)
end

function M.create_bottom_terminal()
  if not M.terminals["bottom"] then
    local Terminal = require("toggleterm.terminal").Terminal
    M.terminals["bottom"] = Terminal:new {
      cmd = vim.o.shell,
      direction = "horizontal",
      hidden = true,
    }
  end

  M.terminals["bottom"]:toggle()

  return M.terminals["bottom"]
end

function M.create_buffer_terminal()
  local current = vim.fn.expand "%:p:h"

  local t = M.create_float_terminal()

  t:toggle()

  if t.dir ~= current then
    t:change_dir(current)
  end

  return t
end

function M.get_all()
  local terms = require "toggleterm.terminal"

  local all_terminals = {}
  for _, value in pairs { terms.get_all(true), M.terminals, M.float_terminals } do
    vim.list_extend(all_terminals, value)
  end

  return all_terminals
end

function M.close_all()
  local all_terminals = M.get_all()

  for _, terminal in pairs(all_terminals) do
    if terminal:is_open() or terminal:is_focused() then
      terminal:close()
    end
  end

  -- let ranger act as terminal as well
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

function M.kill_all()
  local all_terminals = M.get_all()

  for _, terminal in pairs(all_terminals) do
    terminal:shutdown()
  end

  M.float_terminals = {}
  M.float_terminal_current = 0
end

---Toggles a log viewer according to log.viewer.layout_config
---@param logfile string the fullpath to the logfile
function M.toggle_log_view(logfile)
  local log_viewer = lvim.log.viewer.cmd
  if vim.fn.executable(log_viewer) ~= 1 then
    log_viewer = "less +F"
  end
  Log:debug("attempting to open: " .. logfile)
  log_viewer = log_viewer .. " " .. logfile
  local term_opts = vim.tbl_deep_extend("force", M.current_setup(), {
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

M.current_setup = require("utils.setup").get_current_setup(extension_name)

return M