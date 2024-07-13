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
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.DEBUG, "d" }),
          function()
            require("dap").toggle_breakpoint()
          end,
          desc = "breakpoint",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "D" }),
          function()
            vim.ui.input({
              prompt = "Conditional breakpoint: ",
              highlight = require("utils").treesitter_highlight(vim.bo.filetype),
            }, function(value)
              require("dap").set_breakpoint(value, nil, nil)
            end)
          end,
          desc = "conditional breakpoint",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "l" }),
          function()
            vim.ui.input({
              prompt = "Log: ",
              highlight = require("utils").treesitter_highlight(vim.bo.filetype),
            }, function(value)
              require("dap").set_breakpoint(nil, nil, value)
            end)
          end,
          desc = "log point",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "b" }),
          function()
            require("dap").step_back()
          end,
          desc = "step back",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "c" }),
          function()
            require("dap").continue()
          end,
          desc = "continue",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "C" }),
          function()
            require("dap").run_to_cursor()
          end,
          desc = "run to cursor",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "F" }),
          function()
            require("dap").run_last()
          end,
          desc = "run last",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "g" }),
          function()
            require("dap").session()
          end,
          desc = "get session",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "i" }),
          function()
            require("dap").step_into()
          end,
          desc = "step into",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "o" }),
          function()
            require("dap").step_over()
          end,
          desc = "step over",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "k" }),
          function()
            require("dap.ui.widgets").hover()
          end,
          desc = "inspect element",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "K" }),
          function()
            require("dap.ui.widgets").preview()
          end,
          desc = "preview",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "L" }),
          function()
            require("dap").list_breakpoints()
          end,
          desc = "list breakpoints",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "O" }),
          function()
            require("dap").step_out()
          end,
          desc = "step out",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "P" }),
          function()
            require("dap").pause()
          end,
          desc = "pause",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "r" }),
          function()
            require("dap").repl.toggle()
          end,
          desc = "toggle repl",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "R" }),
          function()
            require("dap.ext.vscode").load_launchjs()
          end,
          desc = "reload launch.json",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "q" }),
          function()
            require("dap").close()
          end,
          desc = "quit",
        },
        {
          fn.wk_keystroke({ categories.DEBUG, "Q" }),
          function()
            require("dap").disconnect()
          end,
          desc = "disconnect",
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
