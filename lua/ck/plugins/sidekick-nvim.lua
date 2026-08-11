-- https://github.com/folke/sidekick.nvim
local M = {}

local log = require("ck.log")

M.name = "folke/sidekick.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.copilot.nes.enabled or vim.tbl_contains(nvim.lsp.ai.chat.provider, "hyprpilot"), {
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

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            ft = "sidekick_terminal",
            title = "Sidekick",
            size = {
              width = nvim.ui.dimensions.dock("width", "xl"),
            },
          },
        })

        return c
      end)
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
          fn.wk_keystroke({ categories.COPILOT }),
          group = "sidekick",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            M.toggle_instance()
          end,
          desc = "toggle [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "<Space>" }),
          function()
            M.focus_instance()
          end,
          desc = "focus [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "C" }),
          function()
            M.create_instance()
          end,
          desc = "new [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "f" }),
          function()
            M.pick_instance()
          end,
          desc = "pick instance [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "n" }),
          function()
            M.select_instance("next")
          end,
          desc = "next [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "p" }),
          function()
            M.select_instance("prev")
          end,
          desc = "previous [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "<CR>" }),
          function()
            require("sidekick.cli").prompt(function(_, text)
              if text then
                M.send_instance({ text = text })
              end
            end)
          end,
          desc = "pick prompt/context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "a" }),
          function()
            M.send_instance({ msg = "{file}" })
          end,
          desc = "send current file [sidekick]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "a" }),
          function()
            M.send_instance({ msg = "{selection}" })
          end,
          desc = "send selection [sidekick]",
          mode = { "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "." }),
          function()
            M.send_instance({ msg = "{this}" })
          end,
          desc = "send this [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "b" }),
          function()
            M.send_instance({ msg = "{buffers}" })
          end,
          desc = "send buffers [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "d" }),
          function()
            M.send_instance({ msg = "{diagnostics}" })
          end,
          desc = "send diagnostics [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "q" }),
          function()
            M.send_instance({ msg = "{quickfix}" })
          end,
          desc = "send quickfix [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "X" }),
          function()
            M.close_instance()
          end,
          desc = "close [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "A" }),
          function()
            M.open_instance_picker("files")
          end,
          desc = "add file context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "B" }),
          function()
            M.open_instance_picker("buffers")
          end,
          desc = "add buffer context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "G" }),
          function()
            M.open_instance_picker("grep")
          end,
          desc = "add grep context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "D" }),
          function()
            M.open_instance_picker("diagnostics")
          end,
          desc = "add diagnostics context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "Q" }),
          function()
            M.open_instance_picker("qflist")
          end,
          desc = "add quickfix context [sidekick]",
          mode = { "n", "v" },
        },
      }
    end,
    on_setup = function(config)
      require("sidekick").setup(config)
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = { "User" },
          pattern = "SidekickCliAttach",
          group = "sidekick.cleanup",
          callback = function(args)
            M.adopt_session(args.data and args.data.id)
          end,
        },
        {
          event = { "User" },
          pattern = "SidekickCliDetach",
          group = "sidekick.cleanup",
          callback = function(args)
            M.forget_instance(args.data and args.data.id)
          end,
        },
      }
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

---@class SidekickInstance
---@field index integer
---@field name string
---@field session? string session id reported by sidekick once the tool actually launched

---@type table<integer, SidekickInstance>
M.instances = {}
M.current_instance = 0
-- monotonic, never reused: sidekick derives its session id from `<tool-name> <cwd-hash>`, so recycling a
-- name makes a fresh instance collide with the session of the one that just died.
M.instance_count = 0

function M.instance_config()
  return {
    cmd = {
      "hyprpilot",
      "--with-config",
      "@" .. vim.json.encode({
        mcps = {
          {
            mcpServers = {
              ["hyprpilot_nvim"] = {
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
      HYPRPILOT_NO_TITLE = "1",
    },
    url = "https://github.com/hyprpilot/hyprpilot",
  }
end

---@return SidekickInstance
function M.register_instance()
  M.instance_count = M.instance_count + 1

  ---@type SidekickInstance
  local instance = {
    index = M.instance_count,
    name = ("hyprpilot-%d"):format(M.instance_count),
  }

  M.instances[instance.index] = instance
  require("sidekick.config").cli.tools[instance.name] = M.instance_config()

  return instance
end

function M.unregister_instance(index)
  local instance = M.instances[index]

  if not instance then
    return
  end

  M.instances[index] = nil
  require("sidekick.config").cli.tools[instance.name] = nil

  if M.current_instance == index then
    M.current_instance = 0
  end

  log:debug("Sidekick instance removed: %s", instance.name)
end

---@param instance SidekickInstance
function M.instance_opts(instance, opts)
  local base = { name = instance.name }

  -- once the session id is known, target it directly: the tool name alone also matches sessions
  -- started from another cwd, which is how sends end up in the wrong terminal.
  if instance.session then
    base.filter = { session = instance.session }
  end

  return vim.tbl_deep_extend("force", base, opts or {})
end

-- reconciles the registry against what sidekick actually has attached: drops instances whose session
-- died and refreshes the recorded session id. run this before trusting `M.instances` for anything.
---@return SidekickInstance[]
function M.live_instances()
  local states = require("sidekick.cli.state").get({ attached = true })
  local by_session, by_name = {}, {}

  for _, state in ipairs(states) do
    if state.session then
      by_session[state.session.id] = state
    end

    if not by_name[state.tool.name] then
      by_name[state.tool.name] = state
    end
  end

  local instances = {}

  for index, instance in pairs(M.instances) do
    local state = instance.session and by_session[instance.session] or (not instance.session and by_name[instance.name])

    if state then
      instance.session = state.session and state.session.id or instance.session

      table.insert(instances, vim.tbl_extend("force", instance, { state = state }))
    elseif instance.session then
      -- was live, is not anymore. sidekick only reaps a dead session when something asks for the
      -- attached list, so this pass is what makes the removal happen at all.
      M.unregister_instance(index)
    end
  end

  table.sort(instances, function(a, b)
    return a.index < b.index
  end)

  return instances
end

---@return SidekickInstance?
function M.current_instance_or_nil()
  local instances = M.live_instances()

  if vim.tbl_isempty(instances) then
    M.current_instance = 0

    return nil
  end

  for _, instance in ipairs(instances) do
    if instance.index == M.current_instance then
      return instance
    end
  end

  M.current_instance = instances[1].index

  return instances[1]
end

---@param fn fun(instance: SidekickInstance): any
function M.with_current_instance(fn)
  local instance = M.current_instance_or_nil()

  if not instance then
    log:warn("No sidekick instances.")

    return
  end

  return fn(instance)
end

function M.show_instance(index)
  local instance = M.instances[index]

  if not instance then
    return
  end

  local previous = M.instances[M.current_instance]

  if previous and previous.index ~= index then
    require("sidekick.cli").hide(M.instance_opts(previous, { filter = { attached = true } }))
  end

  M.current_instance = index
  require("sidekick.cli").show(M.instance_opts(instance, { focus = true }))
  M.confirm_instance(index)
end

-- sidekick marks a session attached even when the job failed to spawn: `Session.attach` sets
-- `_attached` after `start()` already gave up. the reap that undoes it only runs because
-- `sidekick.status` happens to hook the attach event -- too incidental to rely on, so confirm here.
function M.confirm_instance(index)
  vim.schedule(function()
    local instance = M.instances[index]

    if not instance then
      return
    end

    for _, live in ipairs(M.live_instances()) do
      if live.index == index then
        log:debug("Sidekick instance launched: %s [%s]", instance.name, instance.session or "?")

        return
      end
    end

    log:warn("Sidekick instance failed to launch: %s", instance.name)
    M.unregister_instance(index)
  end)
end

---@return SidekickInstance
function M.create_instance()
  local instance = M.register_instance()

  M.show_instance(instance.index)

  return instance
end

function M.destroy_instance(instance)
  require("sidekick.cli").close(M.instance_opts(instance, { filter = { attached = true } }))
  M.unregister_instance(instance.index)
end

function M.toggle_instance()
  local instance = M.current_instance_or_nil()

  if not instance then
    return M.create_instance()
  end

  require("sidekick.cli").toggle(M.instance_opts(instance, { focus = true }))
end

function M.focus_instance()
  return M.with_current_instance(function(instance)
    -- `cli.focus` pins `focus = false` internally, so passing it here would be inert
    require("sidekick.cli").focus(M.instance_opts(instance, { filter = { attached = true } }))
  end)
end

function M.send_instance(opts)
  return M.with_current_instance(function(instance)
    require("sidekick.cli").send(M.instance_opts(instance, vim.tbl_deep_extend("force", { focus = true, filter = { attached = true } }, opts or {})))
  end)
end

function M.open_instance_picker(kind)
  return M.with_current_instance(function(instance)
    require("sidekick.cli.picker").open(kind, M.instance_opts(instance, { focus = true, filter = { attached = true } }))
  end)
end

function M.close_instance()
  return M.with_current_instance(M.destroy_instance)
end

-- session ids are `<tool> <cwd-hash>`, optionally wrapped as `terminal: <tool> <cwd-hash>` by a mux
-- backend. fall back to the tool prefix for instances that never got as far as recording their id.
---@param instance SidekickInstance
function M.instance_owns_session(instance, session_id)
  if instance.session then
    return instance.session == session_id
  end

  local id = session_id:gsub("^terminal: ", "")

  return id:sub(1, #instance.name + 1) == instance.name .. " "
end

-- sidekick emits attach synchronously from `Session.attach`, the first moment the session id exists.
-- claim it there so instance identity stops depending on the tool name as early as possible.
function M.adopt_session(session_id)
  if not session_id then
    return
  end

  for _, instance in pairs(M.instances) do
    if not instance.session and M.instance_owns_session(instance, session_id) then
      instance.session = session_id

      return
    end
  end
end

function M.forget_instance(session_id)
  if not session_id then
    return
  end

  for index, instance in pairs(M.instances) do
    if M.instance_owns_session(instance, session_id) then
      M.unregister_instance(index)
    end
  end
end

function M.pick_instance()
  local instances = M.live_instances()

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
      results = M.live_instances(),
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

          M.destroy_instance(entry.value)

          local picker = action_state.get_current_picker(prompt_bufnr)
          local remaining = M.live_instances()
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
  local instances = M.live_instances()

  if vim.tbl_isempty(instances) then
    log:warn("No sidekick instances.")
    return
  end

  local position
  for i, instance in ipairs(instances) do
    if instance.index == M.current_instance then
      position = i
      break
    end
  end

  if not position then
    -- nothing current: enter the ring from whichever end the direction implies
    position = action == "prev" and #instances or 1
  elseif action == "next" then
    position = position == #instances and 1 or position + 1
  elseif action == "prev" then
    position = position == 1 and #instances or position - 1
  end

  M.show_instance(instances[position].index)

  log:debug("Sidekick switched: %s", instances[position].name)
end

return M
