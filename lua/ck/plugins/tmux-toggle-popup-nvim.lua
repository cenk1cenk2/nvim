-- https://github.com/cenk1cenk2/tmux-toggle-popup.nvim
local M = {}

M.name = "cenk1cenk2/tmux-toggle-popup.nvim"

local log = require("ck.log")

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "cenk1cenk2/tmux-toggle-popup.nvim",
        -- dir = "~/development/tmux-toggle-popup.nvim",
      }
    end,
    configure = function()
      if vim.env["TMUX"] then
        nvim.fn.toggle_log_view = M.toggle_log_view
      end

      for key, value in pairs(M.editor_block()) do
        vim.env[key] = value
      end
    end,
    setup = function()
      ---@type tmux-toggle-popup.Config
      return {
        -- log_level = vim.log.levels.DEBUG,
        log_level = require("ck.log"):to_nvim_level(),
        env = {
          VISUAL = function()
            return vim.env["VISUAL"]
          end,
          EDITOR = function()
            return vim.env["EDITOR"]
          end,
          GIT_EDITOR = function()
            return vim.env["GIT_EDITOR"]
          end,
          EDITOR_BLOCK = function()
            return vim.env["EDITOR_BLOCK"]
          end,
        },
        on_init = {
          "set exit-empty on",
          "set -g status on",
        },
        toggle = {
          key = "-n F1",
          mode = "force-close",
        },
      }
    end,
    on_setup = function(c)
      require("tmux-toggle-popup").setup(c)
    end,
    keymaps = function()
      if not vim.env["TMUX"] then
        return {}
      end

      return {
        {
          "<F1>",
          function()
            require("tmux-toggle-popup").open()
          end,
          desc = "toggle tmux popup",
        },
        {
          "<F5>",
          function()
            local dir = require("ck.utils.fs").get_buffer_dirpath()

            M.create_terminal({
              name = dir,
              flags = {
                start_directory = dir,
              },
            })
          end,
          desc = "create buffer terminal",
        },
      }
    end,
    wk = function(_, categories, fn)
      if not vim.env["TMUX"] then
        return {}
      end

      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TERMINAL, "s" }),
          function()
            require("tmux-toggle-popup").save()
          end,
          desc = "save session for main terminal",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "S" }),
          function()
            require("tmux-toggle-popup").save_all()
          end,
          desc = "save session for all terminals",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "x" }),
          function()
            require("tmux-toggle-popup").kill()
          end,
          desc = "kill session for main terminal",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "X" }),
          function()
            require("tmux-toggle-popup").kill_all()
          end,
          desc = "kill session for all terminals",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "g" }),
          function()
            M.create_terminal({
              name = "lazygit",
              env = {
                PATH = ("%s:%s"):format(vim.fn.expand("~/.local/share/mise/shims"), vim.env["PATH"]),
              },
              command = { "lazygit" },
            })
          end,
          desc = "lazygit",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "d" }),
          function()
            M.create_terminal({
              name = "lazydocker",
              env = {
                PATH = ("%s:%s"):format(vim.fn.expand("~/.local/share/mise/shims"), vim.env["PATH"]),
              },
              command = { "lazydocker" },
            })
          end,
          desc = "lazydocker",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "k" }),
          function()
            M.create_terminal({
              name = "k9s",
              env = {
                PATH = ("%s:%s"):format(vim.fn.expand("~/.local/share/mise/shims"), vim.env["PATH"]),
              },
              command = { "k9s" },
            })
          end,
          desc = "k9s",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "y" }),
          function()
            M.create_terminal({
              name = "yazi",
              env = M.editor_async(),
              command = { "yazi" },
            })
          end,
          desc = "yazi",
        },
      }
    end,
  })
end

---@return table<string, string>
function M.editor_block()
  local editor = "nvim -b"

  return {
    VISUAL = editor,
    EDITOR = editor,
    GIT_EDITOR = editor,
    EDITOR_BLOCK = "1",
  }
end

---@return table<string, string>
function M.editor_async()
  local editor = "nvim"

  return {
    VISUAL = editor,
    EDITOR = editor,
    GIT_EDITOR = editor,
    EDITOR_BLOCK = "",
  }
end

---@param opts tmux-toggle-popup.Session
function M.create_terminal(opts)
  return require("tmux-toggle-popup").open(vim.tbl_extend("keep", opts, { on_init = { "set status off" } }))
end

---@param file string the fullpath to the logfile
function M.toggle_log_view(file)
  local cmd = nvim.log.viewer.cmd

  log:debug("Attempting to open log file: %s", file)

  return M.create_terminal({
    name = "log",
    command = { cmd, file },
  })
end

return M
