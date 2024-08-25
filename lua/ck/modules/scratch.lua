local M = {}

local log = require("ck.log")

local random = math.random
local function uuid()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return string.gsub(template, "[xy]", function(c)
    local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
    return string.format("%x", v)
  end)
end

function M.create_scratch_buffer()
  local filetypes = vim.fn.getcompletion("", "filetype")

  vim.ui.select(filetypes, {
    prompt = "Select a filetype",
  }, function(filetype)
    if filetype == nil then
      log:warn("Nothing to create.")

      return
    end

    local bufnr = vim.api.nvim_create_buf(true, false)
    local filename = string.format("_scratch-%s.%s", uuid(), filetype)
    vim.api.nvim_buf_set_name(bufnr, filename)
    vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
    vim.api.nvim_win_set_buf(0, bufnr)
    log:info("Created temporary file: %s", filename)

    require("ck.setup").create_autocmds({
      {
        event = { "BufDelete", "VimLeavePre" },
        group = "_scratch",
        buffer = bufnr,
        callback = function()
          os.remove(filename)

          log:info("Removed temporary file: %s", filename)
        end,
      },
    })
  end)
end

function M.execute_scratch_buffer()
  local shada = require("ck.modules.shada")
  local store_key = "EXECUTE_SCRATCH_BUFFER_LAST"
  local stored_value = shada.get(store_key)

  -- local bufnr = vim.api.nvim_get_current_buf()
  local Terminal = require("ck.plugins.toggleterm-nvim")

  vim.ui.input({
    prompt = "Command",
    default = stored_value,
  }, function(command)
    if command == nil then
      log:warn("Nothing to execute.")

      return
    end

    shada.set(store_key, command)
    --
    -- local contents = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
    --
    -- local filename = string.format("%s.tmp", uuid())
    -- local temp = io.open(filename, "w")
    -- log:debug(string.format("Created temporary file: %s", filename))
    --
    -- if temp == nil then
    --   log:error "Can not create temporary file."
    --   return
    -- end
    --
    -- temp:write(contents)
    -- temp:flush()

    local terminal = Terminal.create_terminal(Terminal.generate_defaults_float_terminal({
      cmd = string.format("%s -c '%s %s'", vim.o.shell, command, vim.fn.expand("%")),
      close_on_exit = false,
      dir = require("ck.utils.fs").get_cwd(),
      on_exit = function()
        -- temp:close()
        -- log:debug(string.format("Closing temporary file: %s", filename))
        --
        -- os.remove(filename)
        -- log:debug(string.format("Removed temporary file: %s", filename))
      end,
    }))

    terminal:open()
  end)
end

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "o" }),
          function()
            M.create_scratch_buffer()
          end,
          desc = "create scratch buffer",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "S" }),
          function()
            M.execute_scratch_buffer()
          end,
          desc = "execute current scratch buffer",
        },
      }
    end,
  })
end

return M
