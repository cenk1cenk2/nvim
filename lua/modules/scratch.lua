local M = {}

local Log = require "lvim.core.log"

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
      Log:warn "Nothing to create."

      return
    end

    local bufnr = vim.api.nvim_create_buf(true, false)
    local filename = string.format("_scratch-%s.%s", uuid(), filetype)
    vim.api.nvim_buf_set_name(bufnr, filename)
    vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)
    vim.api.nvim_win_set_buf(0, bufnr)
    Log:info(string.format("Created temporary file: %s", filename))

    local augroup = "_scratch"
    vim.api.nvim_create_augroup(augroup, {})
    vim.api.nvim_create_autocmd("BufDelete", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        os.remove(filename)

        Log:info(string.format("Removed temporary file: %s", filename))
      end,
    })
  end)
end

function M.execute_scratch_buffer()
  local store_key = "EXECUTE_SCRATCH_BUFFER_LAST"
  local stored_value = lvim.store.get_store(store_key)

  -- local bufnr = vim.api.nvim_get_current_buf()
  local Terminal = require "extensions.toggleterm-nvim"

  vim.ui.input({
    prompt = "Command",
    default = stored_value,
  }, function(command)
    if command == nil then
      Log:warn "Nothing to execute."

      return
    end

    -- lvim.store.set_store(store_key, command)
    --
    -- local contents = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
    --
    -- local filename = string.format("%s.tmp", uuid())
    -- local temp = io.open(filename, "w")
    -- Log:debug(string.format("Created temporary file: %s", filename))
    --
    -- if temp == nil then
    --   Log:error "Can not create temporary file."
    --   return
    -- end
    --
    -- temp:write(contents)
    -- temp:flush()

    local terminal = Terminal.create_terminal(Terminal.generate_defaults_float_terminal {
      cmd = string.format("%s -c '%s %s'", vim.o.shell, command, vim.fn.expand "%"),
      close_on_exit = false,
      dir = vim.fn.getcwd(),
      on_exit = function()
        -- temp:close()
        -- Log:debug(string.format("Closing temporary file: %s", filename))
        --
        -- os.remove(filename)
        -- Log:debug(string.format("Removed temporary file: %s", filename))
      end,
    })

    terminal:open()
  end)
end

function M.setup()
  require("utils.setup").run {
    name = "scratch",
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          s = {
            function()
              M.create_scratch_buffer()
            end,
            "create scratch buffer",
          },
          S = {
            function()
              M.execute_scratch_buffer()
            end,
            "execute current scratch buffer",
          },
        },
      }
    end,
  }
end

return M
