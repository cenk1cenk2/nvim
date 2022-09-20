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
        name_formatter = function(term) --  term: Terminal
          return term.name
        end,
      },
      -- on_open = M._on_open,
      -- Add executables on the config.lua
      execs = {
        { cmd = "lazygit", keymap = "g", label = "LazyGit" },
        { cmd = "lazydocker", keymap = "d", label = "LazyDocker" },
        { cmd = "htop", keymap = "h", label = "htop" },
        { cmd = "ncdu", keymap = "n", label = "ncdu" },
      },
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

      for i, exec in pairs(config.setup.execs) do
        local opts = {
          cmd = exec.cmd,
          keymap = exec.keymap,
          label = exec.label,
          -- NOTE: unable to consistently bind id/count <= 9, see #2146
          count = i + 100,
          direction = exec.direction or M.current_setup().direction,
          size = M.current_setup().size,
        }

        M.add_exec(opts)
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
            M.buffer_terminal()
          end,
          "buffer cwd terminal",
        },

        ["B"] = {
          function()
            M.bottom_terminal()
          end,
          "bottom terminal",
        },

        ["X"] = {
          function()
            M.terminal_kill_all()
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

function M.add_exec(opts)
  local binary = opts.cmd:match "(%S+)"
  if vim.fn.executable(binary) ~= 1 then
    Log:debug("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
    return
  end

  require("utils.setup").load_wk_mappings {
    ["t"] = {
      [opts.keymap] = {
        function()
          M._exec_toggle { cmd = opts.cmd, count = opts.count, direction = opts.direction }
        end,
        opts.label,
      },
    },
  }
end

M.terminals = {}
M.float_terminals = {}
M.float_terminal_current = 1

function M._on_open(term)
  -- vim.api.nvim_set_current_win(term.window)
  term:focus()
end

function M._exec_toggle(exec)
  if not M.terminals[exec.cmd] then
    local Terminal = require("toggleterm.terminal").Terminal

    M.terminals[exec.cmd] = Terminal:new {
      cmd = exec.cmd,
      hidden = true,
    }
  end

  M.terminals[exec.cmd]:toggle()

  return M.terminals[exec.cmd]
end

function M.current_float_terminal()
  if not M.float_terminals[M.float_terminal_current] then
    M.float_terminal_current = 1
  end

  if vim.tbl_isempty(M.float_terminals) then
    M.create_float_terminal()
  end

  Log:debug("Terminal switched: " .. M.float_terminal_current)

  return M.float_terminals[M.float_terminal_current]
end

function M.create_float_terminal()
  local Terminal = require("toggleterm.terminal").Terminal

  local index = vim.tbl_count(M.float_terminals) + 1

  Log:debug("Terminal created: " .. index)

  table.insert(
    M.float_terminals,
    index,
    Terminal:new {
      cmd = vim.o.shell,
      direction = "float",
      hidden = true,
      on_exit = function(terminal)
        for i, t in pairs(M.float_terminals) do
          if t.id == terminal.id then
            table.remove(M.float_terminals, i)
          end
        end

        if M.float_terminal_current > vim.tbl_count(M.float_terminals) then
          M.float_terminal_current = vim.tbl_count(M.float_terminals)
        elseif M.float_terminal_current < index then
          M.float_terminal_current = M.float_terminal_current - 1
        end
      end,
    }
  )

  M.float_terminal_current = index

  return M.float_terminals[index]
end

function M.create_and_open_float_terminal()
  if not vim.tbl_isempty(M.float_terminals) and M.current_float_terminal():is_open() then
    M.current_float_terminal():close()
  end

  M.create_float_terminal()

  M.current_float_terminal():open()
end

function M.float_terminal_select(action)
  if M.current_float_terminal():is_open() then
    M.current_float_terminal():close()
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

  local current = M.current_float_terminal()
  current:open()
end

function M.bottom_terminal()
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

function M.buffer_terminal()
  local current = vim.fn.expand "%:p:h"

  local t = M.create_float_terminal()

  t:toggle()

  if t.dir ~= current then
    t:change_dir(current)
  end

  return t
end

function M.get_all_terminals()
  local terms = require "toggleterm.terminal"

  local all_terminals = {}
  for _, value in pairs { terms.get_all(), M.terminals, M.float_terminals } do
    vim.list_extend(all_terminals, value)
  end

  return all_terminals
end

function M.terminal_kill_all()
  local all_terminals = M.get_all_terminals()

  for _, terminal in pairs(all_terminals) do
    terminal:shutdown()
  end

  M.float_terminals = {}
  M.float_terminal_current = 0
end

function M.close_all()
  local all_terminals = M.get_all_terminals()

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
