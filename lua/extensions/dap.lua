-- https://github.com/mfussenegger/nvim-dap
local M = {}

local extension_name = "dap"

-- local log = require "lvim.core.log"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "mfussenegger/nvim-dap",
        event = "BufWinEnter",
        requires = {},
        config = function()
          require("utils.setup").packer_config "dap"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        dap = require "dap",
        vscode = require "dap.ext.vscode",
        widgets = require "dap.ui.widgets",
        get_debugger = M.get_debugger,
      }
    end,
    on_done = function(config)
      config.inject.vscode.load_launchjs()
    end,
    signs = {
      DapBreakpoint = {
        text = "",
        texthl = "LspDiagnosticsSignError",
        linehl = "",
        numhl = "",
      },
      DapBreakpointRejected = {
        text = "",
        texthl = "LspDiagnosticsSignHint",
        linehl = "",
        numhl = "",
      },
      DapStopped = {
        text = "",
        texthl = "LspDiagnosticsSignInformation",
        linehl = "DiagnosticUnderlineInfo",
        numhl = "LspDiagnosticsSignInformation",
      },
    },
    wk = function(config, categories)
      local dap = config.inject.dap
      local widgets = config.inject.widgets
      local vscode = config.inject.vscode

      return {
        [categories.DEBUG] = {
          d = {
            function()
              dap.toggle_breakpoint()
            end,
            "breakpoint",
          },
          b = {
            function()
              dap.step_back()
            end,
            "step back",
          },
          c = {
            function()
              dap.continue()
            end,
            "continue",
          },
          C = {
            function()
              dap.run_to_cursor()
            end,
            "run to cursor",
          },
          D = {
            function()
              dap.disconnect()
            end,
            "disconnect",
          },
          g = {
            function()
              dap.session()
            end,
            "get session",
          },
          i = {
            function()
              dap.step_into()
            end,
            "step into",
          },
          o = {
            function()
              dap.step_over()
            end,
            "step over",
          },
          k = {
            function()
              widgets.hover()
            end,
            "inspect element",
          },
          L = {
            function()
              dap.list_breakpoints()
            end,
            "list breakpoints",
          },
          O = {
            function()
              dap.step_out()
            end,
            "step out",
          },
          p = {
            function()
              dap.pause()
            end,
            "Pause",
          },
          r = {
            function()
              dap.repl.toggle()
            end,
            "toggle repl",
          },
          R = {
            function()
              vscode.load_launchjs()
            end,
            "reload launch.json",
          },
          q = {
            function()
              dap.close()
            end,
            "quit",
          },
        },
      }
    end,
    autocmds = function()
      -- local vscode = config.inject.vscode

      return {
        {
          { "BufWritePost" },
          {
            group = "__DEBUG_LAUNCHER",
            pattern = "launch.json",
            -- command = function()
            --   vscode.load_launchjs()
            --
            --   log:info "Reloaded launch.json."
            -- end,
            command = ":lua require('dap.ext.vscode').load_launchjs()",
          },
        },
      }
    end,
  })
end

function M.get_debugger(name)
  return vim.fn.stdpath "data" .. "/mason/bin/" .. name
end

return M
