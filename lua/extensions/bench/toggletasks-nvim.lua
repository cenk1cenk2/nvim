-- https://github.com/jedrzejboczar/toggletasks.nvim
local M = {}

local extension_name = "toggletasks_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "jedrzejboczar/toggletasks.nvim",
        branch = "toggleterm-default-opts",
        config = function()
          require("utils.setup").packer_config "toggletasks_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        telescope = require "telescope",
        toggleterm_extension = require "extensions.toggleterm-nvim",
      }
    end,
    setup = function(config)
      local toggleterm_extension = config.inject.toggleterm_extension
      return {
        debug = false,
        silent = false, -- don't show "info" messages
        short_paths = true, -- display relative paths when possible
        -- Paths (without extension) to task configuration files (relative to scanned directory)
        -- All supported extensions will be tested, e.g. '.toggletasks.json', '.toggletasks.yaml'
        search_paths = {
          "tasks",
          ".tasks",
          "toggletasks",
          ".toggletasks",
          ".nvim/toggletasks",
        },
        -- Directories to consider when searching for available tasks for current window
        scan = {
          global_cwd = true, -- vim.fn.getcwd(-1, -1)
          tab_cwd = true, -- vim.fn.getcwd(-1, tab)
          win_cwd = true, -- vim.fn.getcwd(win)
          lsp_root = true, -- root_dir for first LSP available for the buffer
          dirs = {}, -- explicit list of directories to search or function(win): dirs
          rtp = false, -- scan directories in &runtimepath
          rtp_ftplugin = false, -- scan in &rtp by filetype, e.g. ftplugin/c/toggletasks.json
        },
        tasks = {}, -- list of global tasks or function(win): tasks
        -- this is basically the "Config format" defined using Lua tables
        -- Language server priorities when selecting lsp_root (default is 0)
        lsp_priorities = {
          ["null-ls"] = -10,
        },
        -- Default values for task configuration options (available options described later)
        toggleterm = toggleterm_extension.generate_defaults_float_terminal {
          close_on_exit = false,
        },
        -- Configuration of telescope pickers
        telescope = {
          spawn = {
            open_single = true, -- auto-open terminal window when spawning a single task
            show_running = true, -- include already running tasks in picker candidates
            -- Replaces default select_* actions to spawn task (and change toggleterm
            -- direction for select horiz/vert/tab)
            mappings = {
              select_float = "<C-f>",
              spawn_smart = "<C-e>", -- all if no entries selected, else use multi-select
              spawn_all = "<M-e>", -- all visible entries
              spawn_selected = nil, -- entries selected via multi-select (default <tab>)
            },
          },
          -- Replaces default select_* actions to open task terminal (and change toggleterm
          -- direction for select horiz/vert/tab)
          select = {
            mappings = {
              select_float = "<C-f>",
              open_smart = "<C-a>",
              open_all = "<M-a>",
              open_selected = "<M-a>",
              kill_smart = "<C-d>",
              kill_all = "<M-d>",
              kill_selected = nil,
              respawn_smart = "<C-r>",
              respawn_all = "<M-r>",
              respawn_selected = nil,
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("toggletasks").setup(config.setup)
    end,
    on_done = function(config)
      config.inject.telescope.load_extension "toggletasks"
    end,
    wk = function(config, categories)
      local telescope = config.inject.telescope

      return {
        [categories.TASKS] = {
          i = { ":ToggleTasksInfo<CR>", "toggletasks info" },
          e = {
            function()
              telescope.extensions.toggletasks.spawn()
            end,
            "toggletasks spawn",
          },
          r = {
            function()
              telescope.extensions.toggletasks.select()
            end,
            "toggletasks select",
          },
          l = {
            function()
              telescope.extensions.toggletasks.edit()
            end,
            "toggletasks edit configurations",
          },
        },
      }
    end,
  })
end

return M
