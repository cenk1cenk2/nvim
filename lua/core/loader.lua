local M = {}

local log = require("core.log")

M.plugins_dir = get_data_dir() .. "/lazy"
M.plugin_manager_dir = M.plugins_dir .. "/lazy.nvim"
M.cache_dir = join_paths(get_cache_dir(), "lazy")

function M.init()
  if not vim.uv.fs_stat(M.plugin_manager_dir) then
    print("Initializing first time setup...")
    print("Installing plugin manager...")

    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      M.plugin_manager_dir,
    })
  end

  vim.opt.rtp:prepend(M.plugin_manager_dir)

  vim.cmd.packadd("cfilter")
end

function M.load()
  log:debug("Loading plugins configurations...")

  local manager_ok, manager = pcall(require, "lazy")

  if not manager_ok then
    log:warn("Skipping loading plugins until plugin manager is installed.")

    return
  end

  local lazy_setup = {
    root = M.plugins_dir, -- directory where plugins will be installed
    defaults = {
      lazy = true, -- should plugins be lazy-loaded?
    },
    lockfile = get_state_dir() .. "/lazy-lock.json", -- lockfile generated after running update.
    ui = {
      -- a number <1 is a percentage., >1 is a fixed size
      size = { width = 0.8, height = 0.8 },
      -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
      border = "single",
    },
    install = {
      -- install missing plugins on startup. This doesn't increase startup time.
      missing = true,
      -- try to load one of these colorscheme when starting an installation during startup
      colorscheme = {},
    },
    checker = {
      -- automatically check for plugin updates
      enabled = true,
      concurrency = nil, ---@type number? set to 1 to check for updates very slowly
      notify = false, -- get a notification when new updates are found
      frequency = 3600, -- check for updates every hour
    },
    change_detection = {
      -- automatically check for config file changes and reload the ui
      enabled = true,
      notify = true, -- get a notification when changes are found
    },
    performance = {
      cache = {
        enabled = true,
      },
      reset_packpath = true,
      rtp = {
        reset = true,
        ---@type string[] list any plugins you want to disable here
        disabled_plugins = {
          "gzip",
          -- "matchit",
          -- "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
    readme = {
      root = get_state_dir() .. "/lazy/readme",
      files = { "README.md" },
      skip_if_doc_exists = true,
    },
  }

  local status_ok, _ = xpcall(function()
    require("setup").set_plugins()

    manager.setup(nvim.plugins, lazy_setup)
  end, debug.traceback)

  if not status_ok then
    log:error("Can not load plugin configurations.")

    log:error(debug.traceback())
  end
end

function M.reload()
  local manager = require("lazy")

  require("setup").set_plugins()

  manager.reload()

  require("lazy.core.plugin").update_state()

  local plugins = manager.plugins()

  local not_installed_plugins = vim.tbl_filter(function(plugin)
    return not plugin._.installed
  end, plugins)

  require("lazy.manage").clear()

  if #not_installed_plugins > 0 then
    manager.install({ wait = true })
  end
  manager.clean({ wait = true })
end

function M.reset_cache()
  os.remove(M.cache_dir)
end

return M
