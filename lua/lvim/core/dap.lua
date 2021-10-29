local M = {}

M.config = function()
  lvim.builtin.dap = {
    active = true,
    on_config_done = nil,
    breakpoint = { text = "", texthl = "LspDiagnosticsSignError", linehl = "", numhl = "" },
    breakpoint_rejected = { text = "", texthl = "LspDiagnosticsSignHint", linehl = "", numhl = "" },
    stopped = {
      text = "",
      texthl = "LspDiagnosticsSignInformation",
      linehl = "DiagnosticUnderlineInfo",
      numhl = "LspDiagnosticsSignInformation",
    },
  }
end

M.setup = function()
  local dap = require "dap"

  vim.fn.sign_define("DapBreakpoint", lvim.builtin.dap.breakpoint)
  vim.fn.sign_define("DapBreakpointRejected", lvim.builtin.dap.breakpoint_rejected)
  vim.fn.sign_define("DapStopped", lvim.builtin.dap.stopped)

  dap.defaults.fallback.terminal_win_cmd = "30hsplit new"

  lvim.builtin.which_key.mappings["d"] = {
    name = "Debug",
    t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
    b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
    c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
    C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
    d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
    g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
    i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
    o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
    k = { "<cmd>lua require('dap.ui.widgets').hover()<cr>", "inspect element" },
    K = { ':lua require("dapui").float_element()<CR>', "floating element" },
    l = { "<cmd>lua require('dap').list_breakpoints()<cr>", "list breakpoints" },
    O = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
    p = { "<cmd>lua require'dap'.pause.toggle()<cr>", "Pause" },
    r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
    R = { "<cmd>lua require('dap.ext.vscode').load_launchjs()<cr>", "Reload launch.json" },
    s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
    u = { ':lua require("dapui").toggle()<CR>', "toggle ui" },
    q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
  }

  local dap_install = require "dap-install"
  local dbg_list = require("dap-install.api.debuggers").get_installed_debuggers()

  for _, debugger in ipairs(dbg_list) do
    dap_install.config(debugger)
  end

  local dbg_path = require("lvim.utils").join_paths(
    require("dap-install.config.settings").options["installation_path"],
    "jsnode/"
  )
  local fn = vim.fn

  dap.configurations.typescript = {
    {
      type = "node2",
      request = "launch",
      name = "run this file ${file}",
      program = "${file}",
      cwd = fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
  }

  require("dap.ext.vscode").load_launchjs()

  if lvim.builtin.dap.on_config_done then
    lvim.builtin.dap.on_config_done(dap)
  end
end

return M
