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
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "sidekick_terminal",
      })
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
          tools = {},
          win = {
            split = {
              width = 0.4,
            },
            keys = {
              buffers = false,
              files = false,
              hide_n = { "q", "hide", mode = "n", desc = "hide the terminal window" },
              hide_ctrl_q = { "<c-q>", "hide", mode = "n", desc = "hide the terminal window" },
              hide_ctrl_dot = false,
              hide_ctrl_z = { "<c- >", "blur", mode = "nt", desc = "go back to the previous window without hiding the terminal" },
              prompt = false,
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
          enabled = function(_)
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
          fn.wk_keystroke({ categories.SIDEKICK }),
          group = "sidekick",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "c" }),
          function()
            require("sidekick.cli").toggle(M.instance_opts({ focus = true }))
          end,
          desc = "toggle [hyprpilot]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "<Space>" }),
          function()
            require("sidekick.cli").focus(M.instance_opts({ focus = true, filter = { attached = true } }))
          end,
          desc = "focus [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "C" }),
          function()
            M.create_instance()
          end,
          desc = "new [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "f" }),
          function()
            M.pick_instance()
          end,
          desc = "pick instance [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "n" }),
          function()
            M.select_instance("next")
          end,
          desc = "next [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "p" }),
          function()
            M.select_instance("prev")
          end,
          desc = "previous [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "<CR>" }),
          function()
            local cli = require("sidekick.cli")

            cli.prompt(function(_, text)
              if text then
                cli.send(M.instance_opts({ focus = true, filter = { attached = true }, text = text }))
              end
            end)
          end,
          desc = "pick prompt/context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "a" }),
          function()
            require("sidekick.cli").send(M.instance_opts({ focus = true, filter = { attached = true }, msg = "{file}" }))
          end,
          desc = "send current file [sidekick]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "a" }),
          function()
            require("sidekick.cli").send(M.instance_opts({ focus = true, filter = { attached = true }, msg = "{selection}" }))
          end,
          desc = "send selection [sidekick]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "." }),
          function()
            require("sidekick.cli").send(M.instance_opts({ focus = true, filter = { attached = true }, msg = "{this}" }))
          end,
          desc = "send this [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "b" }),
          function()
            require("sidekick.cli").send(M.instance_opts({ focus = true, filter = { attached = true }, msg = "{buffers}" }))
          end,
          desc = "send buffers [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "d" }),
          function()
            require("sidekick.cli").send(M.instance_opts({ focus = true, filter = { attached = true }, msg = "{diagnostics}" }))
          end,
          desc = "send diagnostics [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "q" }),
          function()
            require("sidekick.cli").send(M.instance_opts({ focus = true, filter = { attached = true }, msg = "{quickfix}" }))
          end,
          desc = "send quickfix [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "X" }),
          function()
            require("sidekick.cli").close(M.instance_opts({ filter = { attached = true } }))
          end,
          desc = "close [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "A" }),
          function()
            require("sidekick.cli.picker").open("files", M.instance_opts({ focus = true, filter = { attached = true } }))
          end,
          desc = "add file context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "B" }),
          function()
            require("sidekick.cli.picker").open("buffers", M.instance_opts({ focus = true, filter = { attached = true } }))
          end,
          desc = "add buffer context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "G" }),
          function()
            require("sidekick.cli.picker").open("grep", M.instance_opts({ focus = true, filter = { attached = true } }))
          end,
          desc = "add grep context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "D" }),
          function()
            require("sidekick.cli.picker").open("diagnostics", M.instance_opts({ focus = true, filter = { attached = true } }))
          end,
          desc = "add diagnostics context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "Q" }),
          function()
            require("sidekick.cli.picker").open("qflist", M.instance_opts({ focus = true, filter = { attached = true } }))
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

M.instances = {}
M.current_instance = 0

function M.register_instance(index)
  local instance = {
    name = ("hyprpilot-%d"):format(index),
  }

  M.instances[index] = instance

  local ok, config = pcall(require, "sidekick.config")
  if ok then
    config.cli.tools[instance.name] = {
      cmd = {
        "hyprpilot",
        "spawn",
        "--with-config",
        "@" .. vim.json.encode({
          mcps = {
            {
              mcpServers = {
                ["hyprpilot-nvim"] = {
                  command = "uvx",
                  args = { "hyprpilot-nvim-mcp@latest" },
                  env = {
                    NVIM_LISTEN_ADDRESS = vim.v.servername,
                  },
                },
              },
            },
          },
        }),
      },
      env = {
        EDITOR = "nvim",
        VISUAL = "nvim",
        NVIM_FLATTEN_DISABLE = "1",
      },
      url = "https://github.com/hyprpilot/hyprpilot",
    }
  end

  return instance
end

function M.get_current_instance()
  if M.current_instance == 0 then
    M.current_instance = 1
  end

  return M.instances[M.current_instance] or M.register_instance(M.current_instance)
end

function M.instance_opts(opts)
  return vim.tbl_deep_extend("force", {
    name = M.get_current_instance().name,
  }, opts or {})
end

function M.create_instance(index)
  index = index or #M.instances + 1
  M.current_instance = index

  local instance = M.instances[index] or M.register_instance(index)

  require("sidekick.cli").hide({ all = true, filter = { attached = true } })
  require("sidekick.cli").toggle(M.instance_opts({ focus = true }))

  log:debug("Sidekick created: %s", instance.name)

  return instance
end

function M.attached_instances()
  local state = require("sidekick.cli.state")
  local instances = {}

  for index, instance in ipairs(M.instances) do
    local matches = state.get({ name = instance.name, attached = true })
    if #matches > 0 then
      table.insert(
        instances,
        vim.tbl_extend("force", instance, {
          index = index,
          state = matches[1],
        })
      )
    end
  end

  return instances
end

function M.pick_instance()
  local instances = M.attached_instances()

  if vim.tbl_isempty(instances) then
    M.create_instance(1)
    return
  end

  vim.ui.select(instances, {
    prompt = "Select sidekick instance:",
    format_item = function(instance)
      local marker = instance.index == M.current_instance and "*" or " "
      local cwd = instance.state.session and vim.fn.fnamemodify(instance.state.session.cwd, ":p:~") or ""
      local buf = instance.state.terminal and instance.state.terminal.buf and ("buf:%d"):format(instance.state.terminal.buf) or ""

      return ("%s %d: %s %s %s"):format(marker, instance.index, instance.name, buf, cwd)
    end,
  }, function(instance)
    if not instance then
      return
    end

    M.current_instance = instance.index
    require("sidekick.cli").hide({ all = true, filter = { attached = true } })
    require("sidekick.cli").show(M.instance_opts({ focus = true, filter = { attached = true } }))
  end)
end

function M.select_instance(action)
  local instances = M.attached_instances()

  if vim.tbl_isempty(instances) then
    M.create_instance(1)
    return
  end

  local position = 1
  for i, instance in ipairs(instances) do
    if instance.index == M.current_instance then
      position = i
      break
    end
  end

  if action == "next" then
    position = position == #instances and 1 or position + 1
  elseif action == "prev" then
    position = position == 1 and #instances or position - 1
  end

  M.current_instance = instances[position].index
  require("sidekick.cli").hide({ all = true, filter = { attached = true } })
  require("sidekick.cli").show(M.instance_opts({ focus = true, filter = { attached = true } }))

  log:debug("Sidekick switched: %s", M.get_current_instance().name)
end

return M
