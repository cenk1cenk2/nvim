-- https://github.com/folke/sidekick.nvim
local M = {}

local log = require("ck.log")

M.name = "folke/sidekick.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.copilot.nes.enabled, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/sidekick.nvim",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        jump = {
          jumplist = true, -- add an entry to the jumplist
        },
        signs = {
          enabled = true, -- enable signs by default
          icon = nvim.ui.icons.misc.Robot,
        },
        cli = {
          watch = true,
          mux = {
            backend = "tmux",
            enabled = true,
            create = "terminal", ---@type "terminal"|"window"|"split"
            split = {
              vertical = true, -- vertical or horizontal split
              size = 0.4, -- size of the split (0-1 for percentage)
            },
          },
          tools = {
            [M.SIDEKICK_TOOL] = {
              cmd = M.sidekick_cmd(),
              url = "https://github.com/hyprpilot/hyprpilot",
              is_proc = M.SIDEKICK_IS_PROC,
            },
          },
          win = {
            keys = {
              buffers = { "<c-b>", "buffers", mode = "nt", desc = "open buffer picker" },
              files = { "<c-f>", "files", mode = "nt", desc = "open file picker" },
              hide_n = { "q", "hide", mode = "n", desc = "hide the terminal window" },
              hide_ctrl_q = { "<c-q>", "hide", mode = "n", desc = "hide the terminal window" },
              hide_ctrl_dot = { "<c-.>", "hide", mode = "nt", desc = "hide the terminal window" },
              hide_ctrl_z = { "<c-z>", "blur", mode = "nt", desc = "go back to the previous window without hiding the terminal" },
              prompt = { "<c-p>", "prompt", mode = "t", desc = "insert prompt or context" },
              stopinsert = { "<c-q>", "stopinsert", mode = "t", desc = "enter normal mode" },
              -- Navigate windows in terminal mode. Only active when:
              -- * layout is not "float"
              -- * there is another window in the direction
              -- With the default layout of "right", only `<c-h>` will be mapped
              nav_left = { "<c-h>", "nav_left", expr = true, desc = "navigate to the left window" },
              nav_down = { "<c-j>", "nav_down", expr = true, desc = "navigate to the below window" },
              nav_up = { "<c-k>", "nav_up", expr = true, desc = "navigate to the above window" },
              nav_right = { "<c-l>", "nav_right", expr = true, desc = "navigate to the right window" },
            },
          },
        },
        nes = {
          ---@type boolean|fun(buf:integer):boolean?
          enabled = function(buf)
            return vim.g.sidekick_nes ~= false and vim.b.sidekick_nes ~= false and nvim.lsp.ai.copilot.nes.enabled
          end,
          debounce = nvim.lsp.ai.copilot.nes.debounce,
          trigger = {
            -- events that trigger sidekick next edit suggestions
            events = nvim.lsp.ai.copilot.nes.events.suggest,
          },
          clear = {
            -- events that clear the current next edit suggestion
            events = nvim.lsp.ai.copilot.nes.events.clear,
            esc = true, -- clear next edit suggestions when pressing <Esc>
          },
          ---@class sidekick.diff.Opts
          ---@field inline? "words"|"chars"|false Enable inline diffs
          diff = {
            inline = "words",
            show = "cursor",
          },
        },
      }
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "t" }),
          group = "terminals",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "t" }),
          function()
            M.toggle_sidekick()
          end,
          desc = "toggle [hyprpilot]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "r" }),
          function()
            M.toggle_sidekick({ restore = true })
          end,
          desc = "restore cwd [hyprpilot]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "<Space>" }),
          function()
            local opts = M.sidekick_session_opts()
            if opts then
              require("sidekick.cli").focus(opts)
            end
          end,
          desc = "focus [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "<CR>" }),
          function()
            local opts = M.sidekick_session_opts()
            if not opts then
              return
            end

            local cli = require("sidekick.cli")

            cli.prompt(function(_, text)
              if text then
                cli.send(vim.tbl_extend("force", opts, { text = text }))
              end
            end)
          end,
          desc = "pick prompt/context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "f" }),
          function()
            local opts = M.sidekick_session_opts()
            if opts then
              require("sidekick.cli.picker").open("files", opts)
            end
          end,
          desc = "add file context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "b" }),
          function()
            local opts = M.sidekick_session_opts()
            if opts then
              require("sidekick.cli.picker").open("buffers", opts)
            end
          end,
          desc = "add buffer context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "g" }),
          function()
            local opts = M.sidekick_session_opts()
            if opts then
              require("sidekick.cli.picker").open("grep", opts)
            end
          end,
          desc = "add grep context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "d" }),
          function()
            local opts = M.sidekick_session_opts()
            if opts then
              require("sidekick.cli.picker").open("diagnostics", opts)
            end
          end,
          desc = "add diagnostics context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "q" }),
          function()
            local opts = M.sidekick_session_opts()
            if opts then
              require("sidekick.cli.picker").open("qflist", opts)
            end
          end,
          desc = "add quickfix context [sidekick]",
          mode = { "n", "v" },
        },
      }
    end,
    on_setup = function(config)
      require("sidekick").setup(config)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<M-d>",
          function()
            require("sidekick").clear()
          end,
          desc = "nes: abort",
          mode = { "i", "n", "v" },
        },
        {
          "<M-s>",
          function()
            require("sidekick.nes").jump()
          end,
          desc = "nes: jump to start",
          mode = { "i", "n", "v" },
        },
        {
          "<M-a>",
          function()
            local applied = require("sidekick.nes").apply()
            if not applied then
              log:info("Requesting NES...")
              require("sidekick.nes").update()
            end
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
        {
          "<M-f>",
          function()
            require("sidekick.nes").update()
          end,
          desc = "nes: request suggestion",
          mode = { "i", "n", "v" },
        },
      }
    end,
  })
end

M.SIDEKICK_TOOL = "hyprpilot"
M.SIDEKICK_IS_PROC = "\\<hyprpilot\\>\\|\\<claude\\>\\|\\<codex\\>\\|\\<opencode\\>"
M.HYPRPILOT_NVIM_MCP_SERVER = "hyprpilot-nvim"
M.HYPRPILOT_NVIM_MCP_PACKAGE = "hyprpilot-nvim-mcp@latest"

function M.hyprpilot_nvim_mcp_patch()
  return {
    mcps = {
      {
        mcpServers = {
          [M.HYPRPILOT_NVIM_MCP_SERVER] = {
            command = "uvx",
            args = { M.HYPRPILOT_NVIM_MCP_PACKAGE },
            env = {
              NVIM_LISTEN_ADDRESS = vim.v.servername,
            },
          },
        },
      },
    },
  }
end

function M.sidekick_cmd(opts)
  opts = opts or {}

  local cmd = { "hyprpilot", "spawn" }
  if opts.restore then
    cmd[#cmd + 1] = "--restore"
  end
  vim.list_extend(cmd, {
    "--with-config",
    "@" .. vim.json.encode(M.hyprpilot_nvim_mcp_patch()),
  })

  return cmd
end

function M.toggle_sidekick(opts)
  opts = opts or {}

  if not opts.restore then
    require("sidekick.cli").toggle({ name = M.SIDEKICK_TOOL, focus = true })

    return
  end

  require("sidekick.cli.ui.select").select({
    auto = true,
    filter = { name = M.SIDEKICK_TOOL },
    cb = function(state)
      if not state then
        return
      end

      if state.session then
        M.open_sidekick_state(state)

        return
      end

      M.open_sidekick_state(M.sidekick_restore_state(state))
    end,
  })
end

function M.open_sidekick_state(state)
  state = require("sidekick.cli.state").attach(state, { show = true, focus = true })

  if not state.terminal then
    return
  end

  if state.terminal:is_open() and not state.terminal:is_focused() then
    state.terminal:focus()
  end
end

function M.sidekick_restore_state(state)
  local session = require("sidekick.cli.session").new({
    tool = state.tool:clone({
      cmd = M.sidekick_cmd({ restore = true }),
    }),
  })

  return require("sidekick.cli.state").get_state(session)
end

function M.sidekick_session_opts()
  if #require("sidekick.cli.state").get({ name = M.SIDEKICK_TOOL, attached = true }) == 0 then
    log:warn("Start a Hyprpilot Sidekick terminal with <Leader>ctt or <Leader>ctr first.")

    return
  end

  return { name = M.SIDEKICK_TOOL, focus = true, filter = { attached = true } }
end

return M
