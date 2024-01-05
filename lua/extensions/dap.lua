-- https://github.com/mfussenegger/nvim-dap
local M = {}

local extension_name = "dap"

-- local log = require "lvim.core.log"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "mfussenegger/nvim-dap",
        dependencies = {
          "jay-babu/mason-nvim-dap.nvim",
          "rcarriga/nvim-dap-ui",
          "theHamsta/nvim-dap-virtual-text",
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "dap-repl",
        "dap-float",
      })
    end,
    on_done = function()
      require("dap.ext.vscode").load_launchjs()
    end,
    signs = {
      DapBreakpoint = {
        text = lvim.ui.icons.ui.Bug,
        texthl = "DiagnosticWarning",
        linehl = "",
        numhl = "",
      },
      DapBreakpointCondition = {
        text = lvim.ui.icons.ui.Scopes,
        texthl = "DiagnosticWarning",
        linehl = "",
        numhl = "",
      },
      DapLogPoint = {
        text = lvim.ui.icons.ui.Watches,
        texthl = "DiagnosticWarning",
        linehl = "",
        numhl = "",
      },
      DapStopped = {
        text = lvim.ui.icons.ui.BoldArrowRight,
        texthl = "DiagnosticWarning",
        linehl = "",
        numhl = "",
      },
      DapBreakpointRejected = {
        text = lvim.ui.icons.ui.Bug,
        texthl = "DiagnosticError",
        linehl = "",
        numhl = "",
      },
    },
    wk = function(_, categories)
      return {
        [categories.DEBUG] = {
          d = {
            function()
              require("dap").toggle_breakpoint()
            end,
            "breakpoint",
          },
          D = {
            function()
              vim.ui.input({
                prompt = "Conditional breakpoint: ",
                highlight = require("utils").treesitter_highlight(vim.bo.filetype),
              }, function(value)
                require("dap").set_breakpoint(value, nil, nil)
              end)
            end,
            "conditional breakpoint",
          },
          l = {
            function()
              vim.ui.input({
                prompt = "Log: ",
                highlight = require("utils").treesitter_highlight(vim.bo.filetype),
              }, function(value)
                require("dap").set_breakpoint(nil, nil, value)
              end)
            end,
            "log point",
          },
          b = {
            function()
              require("dap").step_back()
            end,
            "step back",
          },
          c = {
            function()
              require("dap").continue()
            end,
            "continue",
          },
          C = {
            function()
              require("dap").run_to_cursor()
            end,
            "run to cursor",
          },
          F = {
            function()
              require("dap").run_last()
            end,
            "run last",
          },
          g = {
            function()
              require("dap").session()
            end,
            "get session",
          },
          i = {
            function()
              require("dap").step_into()
            end,
            "step into",
          },
          o = {
            function()
              require("dap").step_over()
            end,
            "step over",
          },
          k = {
            function()
              require("dap.ui.widgets").hover()
            end,
            "inspect element",
          },
          K = {
            function()
              require("dap.ui.widgets").preview()
            end,
            "preview",
          },
          L = {
            function()
              require("dap").list_breakpoints()
            end,
            "list breakpoints",
          },
          O = {
            function()
              require("dap").step_out()
            end,
            "step out",
          },
          P = {
            function()
              require("dap").pause()
            end,
            "pause",
          },
          r = {
            function()
              require("dap").repl.toggle()
            end,
            "toggle repl",
          },
          R = {
            function()
              require("dap.ext.vscode").load_launchjs()
            end,
            "reload launch.json",
          },
          q = {
            function()
              require("dap").close()
            end,
            "quit",
          },
          Q = {
            function()
              require("dap").disconnect()
            end,
            "disconnect",
          },
        },
      }
    end,
    autocmds = function()
      return {
        {
          { "BufWritePost" },
          {
            group = "_dap",
            pattern = "launch.json",
            callback = function()
              require("dap.ext.vscode").load_launchjs()

              require("lvim.core.log"):info("Reloaded launch.json for dap.")
            end,
          },
        },
      }
    end,
  })
end

return M
