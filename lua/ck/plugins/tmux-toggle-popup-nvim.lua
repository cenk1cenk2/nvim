-- https://github.com/cenk1cenk2/tmux-toggle-popup.nvim
local M = {
  _ = {},
}

M.name = "cenk1cenk2/tmux-toggle-popup.nvim"

local log = require("ck.log")
local job = require("ck.utils.job")

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
        inherit_vim_env = false,
        inherit_env = true,
        env = function()
          local all = vim.fn.environ()
          local env = {}
          for _, k in pairs({
            "PATH",
            "VISUAL",
            "EDITOR",
            "GIT_EDITOR",
            "EDITOR_BLOCK",
            "KUBECONFIG",
            "KUBECONFIG_FILE",
            "AWS_REGION",
            "AWS_DEFAULT_REGION",
            "AWS_PROFILE",
          }) do
            env[k] = all[k]
          end

          return env
        end,
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

      ---@type nil|tmux-toggle-popup.Session
      local buffer_terminal = nil

      ---@type KeymapMappings
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
            if buffer_terminal then
              if require("tmux-toggle-popup.api").has_session(buffer_terminal) then
                log:info("Reusing existing buffer terminal: %s", buffer_terminal.name)
              else
                log:warn("No buffer terminal exists: %s", buffer_terminal.name)
                buffer_terminal = nil
              end
            end

            if not buffer_terminal then
              local dir = require("ck.utils.fs").get_buffer_dirpath()

              buffer_terminal = {
                name = dir,
                flags = {
                  start_directory = dir,
                },
              }
            end

            M.create_terminal(buffer_terminal)
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
              command = { "lazydocker" },
            })
          end,
          desc = "lazydocker",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "k" }),
          function()
            local context
            if not M._.kubecontext then
              local stdout, code = job
                .create({
                  command = "kubectl",
                  args = { "config", "current-context" },
                  log = {
                    on_success = false,
                  },
                })
                :sync(3000)

              if code > 0 then
                error("Can not fetch current Kubernetes context.")
              end

              context = table.concat(stdout, "")
            else
              context = M._.kubecontext

              log:info("Overwriting kubecontext with local state: %s", context)
            end

            M.create_terminal({
              name = "k9s",
              id_format = ("#{session_name}/k9s/%s"):format(context),
              command = { "k9s", "--context", context },
            })
          end,
          desc = "k9s",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "K" }),
          function()
            local stdout, code = job
              .create({
                command = "kubectl",
                args = { "config", "get-contexts", "-o", "name" },
                log = {
                  on_success = false,
                },
              })
              :sync(3000)

            if code > 0 then
              error("Can not fetch available Kubernetes contexts.")
            end

            vim.ui.select(vim.list_extend({ "reset" }, stdout), { prompt = "Select Kubernetes context:" }, function(context)
              M._.kubecontext = context

              if not context or context == "reset" then
                M._.kubecontext = nil
                log:info("Kubecontext cleared for current session.")

                local stdout, code = job
                  .create({
                    command = "kubectl",
                    args = { "config", "current-context" },
                    log = {
                      on_success = false,
                    },
                  })
                  :sync(3000)

                if code > 0 then
                  error("Can not fetch current Kubernetes context.")
                end

                context = table.concat(stdout, "")
              else
                log:info("Kubecontext set for current session: %s", context)
              end

              M.create_terminal({
                name = "k9s",
                id_format = ("#{session_name}/k9s/%s"):format(context),
                command = { "k9s", "--context", context },
              })
            end)
          end,
          desc = "k9s (with context)",
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
---@return tmux-toggle-popup.Session
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
