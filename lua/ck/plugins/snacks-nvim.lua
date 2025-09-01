-- https://github.com/folke/snacks.nvim
local M = {
  _ = {
    ---@type table<string, snacks.toggle>
    toggles = {},
    ---@type WKToggleMappings
    pending_toggles = {},
  },
}

M.name = "folke/snacks.nvim"

local log = require("ck.log")

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/snacks.nvim",
        lazy = false,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "snacks_dashboard",
        "snacks_notif",
        "snacks_notif_history",
        "snacks_terminal",
        "snacks_words",
      })
    end,
    setup = function()
      ---@type snacks.Config
      return {
        bigfile = {
          enabled = false,
          notify = true, -- show notification when big file detected
          size = 2 * 1024 * 1024,
          -- Enable or disable features when big file detected
          ---@param ctx {buf: number, ft:string}
          setup = function(ctx)
            vim.schedule(function()
              vim.bo[ctx.buf].syntax = "off"
              -- vim.bo[ctx.buf].ft = ctx.ft
              vim.treesitter.stop(ctx.buf)
            end)
          end,
        },
        win = {
          border = nvim.ui.border,
        },
        toggle = {
          icon = {
            enabled = nvim.ui.icons.ui.ToggleOn,
            disabled = nvim.ui.icons.ui.ToggleOff,
          },
          -- colors for enabled/disabled states
          color = {
            enabled = "green",
            disabled = "red",
          },
        },
        dashboard = {
          enabled = true,
          preset = M.DASHBOARD,
          pane_gap = 2,
          sections = {
            {
              section = "header",
              align = "left",
            },
            {
              pane = 2,
              indent = 2,
              section = "keys",
              gap = 2,
              padding = 4,
            },
            {
              pane = 2,
              padding = 2,
              gap = 2,
              section = "startup",
            },
          },
        },
        indent = {
          enabled = true,
          only_scope = true,
          animate = {
            enabled = false,
          },
          chunk = {
            enabled = true,
          },
        },
        notifier = {
          enabled = true,
          timeout = 3000,
          level = vim.log.levels.INFO,
          icons = {
            error = nvim.ui.icons.diagnostics.Error .. " ",
            warn = nvim.ui.icons.diagnostics.Warning .. " ",
            info = nvim.ui.icons.diagnostics.Information .. " ",
            debug = nvim.ui.icons.diagnostics.Debug .. " ",
            trace = nvim.ui.icons.diagnostics.Trace .. " ",
          },
          style = "compact",
          width = { min = 50, max = 0.25 },
          height = { min = 1, max = 0.25 },
          more_format = " " .. nvim.ui.icons.ui.BoldArrowDown .. " %d lines ",
        },
        quickfile = {
          enabled = true,
        },
        scroll = {
          enabled = false,
          animate = {
            duration = { step = 7.5, total = 125 },
            easing = "linear",
          },
          -- faster animation when repeating scroll after delay
          animate_repeat = {
            delay = 50, -- delay in ms before using the repeat animation
            duration = { step = 2.5, total = 25 },
            easing = "linear",
          },
        },
        styles = {
          notification = {
            wo = { wrap = true }, -- Wrap notifications
            border = nvim.ui.border,
          },
        },
        zen = {
          enabled = true,
          toggles = {
            dim = false,
          },
          animate = {
            enabled = false,
          },
          win = {
            width = 180,
            backdrop = { transparent = false },
          },
        },
        dim = {
          enabled = true,
          animate = {
            enabled = false,
          },
        },
        words = {
          enabled = true,
        },
      }
    end,
    on_setup = function(c)
      require("snacks").setup(c)
    end,
    on_done = function()
      _G.dd = function(...)
        require("snacks").debug.inspect(...)
      end
      _G.bt = function()
        require("snacks").debug.backtrace()
      end
      -- vim.print = _G.dd

      require("ck.setup").load_toggles(M._.pending_toggles)
      M._.pending_toggles = {}
    end,
    toggles = function(_, categories, fn)
      ---@type WKToggleMappings
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "z" }),
          function()
            return require("snacks").toggle.zen()
          end,
          desc = "zen",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "d" }),
          function()
            return require("snacks").toggle.dim()
          end,
          desc = "dim",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "g" }),
          function()
            return require("snacks").toggle.indent()
          end,
          desc = "indentation guides",
        },
      }
    end,
    keymaps = function()
      return {
        {
          "<M-n>",
          function()
            require("snacks").words.jump(vim.v.count1)
          end,
          desc = "next reference",
          mode = { "n" },
        },
        {
          "<M-p>",
          function()
            require("snacks").words.jump(-vim.v.count1)
          end,
          desc = "previous reference",
          mode = { "n" },
        },
      }
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.SESSION, "w" }),
          function()
            require("snacks").dashboard.open()
          end,
          desc = "dashboard",
        },

        {
          fn.wk_keystroke({ categories.GIT, "o" }),
          function()
            require("snacks").gitbrowse.open({ what = "branch" })
          end,
          desc = "open branch in browser",
          mode = { "n", "v" },
        },

        {
          fn.wk_keystroke({ categories.GIT, "O" }),
          function()
            require("snacks").gitbrowse.open({ what = "file" })
          end,
          desc = "open file in browser",
          mode = { "n", "v" },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({ "snacks_dashboard" }),
      }
    end,
  })
end

---@class BufferDeleteOptions
---@field bufnr? number Buffer to delete. Defaults to the current buffer
---@field force? boolean Delete the buffer even if it is modified
---@field filter? fun(buf: number): boolean Filter buffers to delete
---@field wipe? boolean Wipe the buffer instead of deleting it (see `:h :bwipeout`)

---@param opts? number|BufferDeleteOptions
function nvim.fn.close_buffer(opts)
  if type(opts) == "number" then
    opts = { bufnr = opts }
  end

  opts = opts or {}

  -- https://github.com/echasnovski/mini.bufremove/blob/main/lua/mini/bufremove.lua
  if opts.bufnr == nil then
    opts.bufnr = vim.api.nvim_get_current_buf()
  end

  if not opts.force and require("ck.plugins.bufferline-nvim").is_element_pinned({ id = opts.bufnr }) then
    require("ck.utils").ui_confirm({
      prompt = ("Buffer is pinned. Close anyway?\n%s"):format(require("ck.utils.fs").get_project_buffer_filepath(opts.bufnr)),
      choices = {
        {
          label = "Yes",
          callback = function()
            require("bufferline.groups").remove_element("pinned", require("ck.plugins.bufferline-nvim").get_element(opts.bufnr))

            require("snacks").bufdelete.delete({ buf = opts.bufnr, force = true, wipe = opts.wipe, filter = opts.filter })

            require("bufferline.ui").refresh()
          end,
        },
        {
          label = "Unpin",
          callback = function()
            require("bufferline.groups").remove_element("pinned", require("ck.plugins.bufferline-nvim").get_element(opts.bufnr))

            require("bufferline.ui").refresh()
          end,
        },
        {
          label = "No",
        },
      },
    })

    return
  end

  require("snacks").bufdelete.delete({ buf = opts.bufnr, force = opts.force, wipe = opts.wipe, filter = opts.filter })
end

M.DASHBOARD = {
  header = [[
                ████▒▒▒▒██████
              ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
            ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
            ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
          ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
          ██▒▒▒▒▒▒    ▒▒    ▒▒▒▒▒▒██
          ██▒▒▒▒▒▒  ██▒▒██  ▒▒▒▒▒▒██
          ██▒▒▒▒▒▒  ██▒▒██  ▒▒▒▒▒▒██
            ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
    ██████  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██    ██
    ██▒▒▒▒██  ██▒▒██▒▒▒▒▒▒██▒▒██████▒▒██  ██
  ██████▒▒▒▒██▒▒▒▒▒▒██████▒▒▒▒██▒▒▒▒██  ██▒▒██
██▒▒▒▒▒▒████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████  ██▒▒██
  ██████▒▒▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒████▒▒██
        ██████████▒▒▒▒▒▒██▒▒▒▒██▒▒▒▒▒▒██
              ██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒██████████
        ██████▒▒▒▒▒▒██▒▒██  ██▒▒▒▒▒▒▒▒▒▒▒▒██
      ██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒▒▒██  ████████████
    ██▒▒██████████  ██▒▒▒▒▒▒██
    ████              ██████▒▒██
                            ████
                                ██]],
  keys = {
    {
      key = "SPC w l",
      desc = "Load Last Session",
      action = "<leader>wl",
      icon = nvim.ui.icons.ui.History,
    },
    {
      key = "SPC w f",
      desc = "Sessions",
      action = "<leader>wf",
      icon = nvim.ui.icons.ui.Project,
    },
    {
      key = "SPC p",
      desc = "Find File",
      action = "<leader>p",
      icon = nvim.ui.icons.ui.File,
    },
    {
      key = "<localleader>c",
      desc = "~Config",
      action = function()
        vim.fn.chdir(join_paths(vim.env.HOME, ".config/nvim/"))
        require("possession").load(require("possession.paths").cwd_session_name())
      end,
      icon = nvim.ui.icons.misc.Neovim,
    },
    {
      key = "<localleader>n",
      desc = "~Notes",
      action = function()
        vim.fn.chdir(join_paths(vim.env.HOME, "notes/"))
        require("possession").load(require("possession.paths").cwd_session_name())
      end,
      icon = nvim.ui.icons.misc.Obsidian,
    },
    {
      key = "SPC w q",
      desc = "Quit",
      action = "<leader>wq",
      icon = nvim.ui.icons.ui.SignOut,
    },
  },
}

---@param option string
---@param opts? snacks.toggle.Config | {on?: unknown, off?: unknown}
function M.toggle_global_option(option, opts)
  opts = opts or {}
  local on = opts.on == nil and true or opts.on
  local off = opts.off ~= nil and opts.off or false
  return require("snacks").toggle.new({
    name = option,
    get = function()
      return vim.opt[option]:get() == on
    end,
    set = function(state)
      vim.opt[option] = state and on or off
    end,
  }, opts)
end

---@param option string
---@param opts? snacks.toggle.Config | {on?: unknown, off?: unknown}
function M.toggle_local_option(option, opts)
  opts = opts or {}
  local on = opts.on == nil and true or opts.on
  local off = opts.off ~= nil and opts.off or false
  return require("snacks").toggle.new({
    name = option,
    get = function()
      return vim.opt_local[option]:get() == on
    end,
    set = function(state)
      vim.opt_local[option] = state and on or off
    end,
  }, opts)
end

return M
