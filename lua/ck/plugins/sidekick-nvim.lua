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
          mux = {
            backend = "tmux",
            enabled = false,
            create = "terminal", ---@type "terminal"|"window"|"split"
            split = {
              vertical = true, -- vertical or horizontal split
              size = 0.4, -- size of the split (0-1 for percentage)
            },
          },
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
          prompts = {
            changes = false,
            diagnostics = false,
            diagnostics_all = false,
            document = false,
            explain = false,
            fix = false,
            optimize = false,
            review = false,
            tests = false,
            -- simple context prompts
            buffers = "{buffers}",
            file = "{file}",
            line = "{line}",
            position = "{position}",
            quickfix = "{quickfix}",
            selection = "{selection}",
            ["function"] = "{function}",
            class = "{class}",
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

function M.instance_config()
  return {
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

function M.register_instance(index)
  local instance = {
    name = ("hyprpilot-%d"):format(index),
  }

  M.instances[index] = instance

  local config = require("sidekick.config")
  config.cli.tools[instance.name] = M.instance_config()

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

function M.show_instance(index)
  local previous = M.current_instance

  if previous > 0 and previous ~= index and M.instances[previous] then
    require("sidekick.cli").hide({ name = M.instances[previous].name, filter = { attached = true } })
  end

  M.current_instance = index
  M.get_current_instance()
  require("sidekick.cli").show(M.instance_opts({ focus = true }))
end

function M.create_instance(index)
  if not index then
    index = 1
    while M.instances[index] do
      index = index + 1
    end
  end
  local instance = M.instances[index] or M.register_instance(index)

  M.show_instance(index)

  log:debug("Sidekick created: %s", instance.name)

  return instance
end

function M.attached_instances()
  local state = require("sidekick.cli.state")
  local instances = {}

  for index, instance in pairs(M.instances) do
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

  table.sort(instances, function(a, b)
    return a.index < b.index
  end)

  return instances
end

function M.pick_instance()
  local instances = M.attached_instances()

  if vim.tbl_isempty(instances) then
    log:warn("No sidekick instances.")
    return
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local previewers = require("telescope.previewers")
  local conf = require("telescope.config").values

  local entry_maker = function(instance)
    local marker = instance.index == M.current_instance and "*" or " "
    local cwd = instance.state.session and vim.fn.fnamemodify(instance.state.session.cwd, ":p:~") or ""
    local buf = instance.state.terminal and instance.state.terminal.buf and ("buf:%d"):format(instance.state.terminal.buf) or ""
    local label = ("%s %d: %s %s %s"):format(marker, instance.index, instance.name, buf, cwd)

    return {
      value = instance,
      display = label,
      ordinal = label,
    }
  end

  local finder = function()
    return finders.new_table({
      results = M.attached_instances(),
      entry_maker = entry_maker,
    })
  end

  pickers
    .new({}, {
      prompt_title = "Sidekick instances",
      finder = finder(),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry)
          local terminal = entry.value.state.terminal
          local buf = terminal and terminal.buf
          if not buf or not vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "No terminal buffer available." })
            return
          end

          local line_count = vim.api.nvim_buf_line_count(buf)
          local start = math.max(line_count - 200, 0)
          local lines = vim.api.nvim_buf_get_lines(buf, start, -1, false)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        local delete = function()
          local entry = action_state.get_selected_entry()
          if not entry then
            return
          end

          require("sidekick.cli").close({ name = entry.value.name, filter = { attached = true } })
          M.instances[entry.value.index] = nil
          if M.current_instance == entry.value.index then
            M.current_instance = 0
          end

          local picker = action_state.get_current_picker(prompt_bufnr)
          local remaining = M.attached_instances()
          if vim.tbl_isempty(remaining) then
            actions.close(prompt_bufnr)
            log:warn("No sidekick instances.")
            return
          end

          picker:refresh(finder(), { reset_prompt = true })
        end

        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if entry then
            M.show_instance(entry.value.index)
          end
        end)

        map({ "i", "n" }, "<C-d>", delete)
        map({ "i", "n" }, "<C-x>", delete)

        return true
      end,
    })
    :find()
end

function M.select_instance(action)
  local instances = M.attached_instances()

  if vim.tbl_isempty(instances) then
    log:warn("No sidekick instances.")
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

  M.show_instance(instances[position].index)

  log:debug("Sidekick switched: %s", M.get_current_instance().name)
end

return M
