local Log = {}

Log.levels = {
  TRACE = 1,
  DEBUG = 2,
  INFO = 3,
  WARN = 4,
  ERROR = 5,
}

vim.tbl_add_reverse_lookup(Log.levels)

function Log:set_level(level)
  local logger_ok, _ = xpcall(function()
    local log_level = Log.levels[level:upper()]
    local structlog = require("structlog")
    if structlog then
      local logger = structlog.get_logger("lvim")
      for _, s in ipairs(logger.sinks) do
        s.level = log_level
      end
    end
  end, debug.traceback)

  if not logger_ok then
    Log:warn("Unable to set logger's level: " .. debug.traceback())
  end
end

function Log:init()
  local status_ok, structlog = pcall(require, "structlog")
  if not status_ok then
    return nil
  end

  local log_level = Log.levels[(lvim.log.level):upper() or "WARN"]
  local logger = {
    lvim = {
      sinks = {
        structlog.sinks.File(log_level, self:get_path(), {
          processors = {
            structlog.processors.StackWriter({ "line", "file" }, { max_parents = 3, stack_level = 2 }),
            structlog.processors.Timestamper("%F %H:%M:%S"),
          },
          formatter = structlog.formatters.Format( --
            "%s [%-5s] %-30s",
            { "timestamp", "level", "msg" }
          ),
        }),
      },
    },
  }

  -- if is_headless() then
  logger.lvim.sinks = vim.list_extend(logger.lvim.sinks, {
    structlog.sinks.Console(log_level, {
      async = true,
      processors = {
        structlog.processors.StackWriter({ "line", "file" }, { max_parents = 0, stack_level = 2 }),
        structlog.processors.Timestamper("%H:%M:%S"),
      },
      formatter = structlog.formatters.FormatColorizer( --
        "%s [%-5s] %-30s",
        { "timestamp", "level", "msg" },
        { level = structlog.formatters.FormatColorizer.color_level() }
      ),
    }),
  })
  -- end

  structlog.configure(logger)

  return structlog.get_logger("lvim")
end

--- Configure the sink in charge of logging notifications
---@param notif_handle table The implementation used by the sink for displaying the notifications
function Log:configure_notifications(notif_handle)
  local status_ok, structlog = pcall(require, "structlog")
  if not status_ok then
    return
  end

  -- ensure logger is initialized
  Log:get_logger()

  table.insert(
    self.__handle.sinks,
    structlog.sinks.NvimNotify(Log.levels.INFO, {
      processors = {
        function(logger, entry)
          entry["title"] = logger.name
          return entry
        end,
      },
      formatter = structlog.formatters.Format( --
        "%s",
        { "msg" },
        { blacklist_all = true }
      ),
      impl = notif_handle,
    })
  )

  -- Overwrite `vim.notify` to use the logger
  -- vim.notify = function(msg, level, opts)
  --   notify_opts = opts or {}
  --
  --   if level == nil then
  --     level = Log.levels["INFO"]
  --   elseif type(level) == "string" then
  --     level = Log.levels[(level):upper()] or Log.levels["INFO"]
  --   else
  --     -- https://github.com/neovim/neovim/blob/685cf398130c61c158401b992a1893c2405cd7d2/runtime/lua/vim/lsp/log.lua#L5
  --     level = level + 1
  --   end
  --
  --   self:log(level, msg)
  -- end

  return self
end

--- Adds a log entry using Plenary.log
---@param msg any
---@param level string [same as vim.log.log_levels]
function Log:add_entry(level, msg, event)
  local logger = self:get_logger()
  if not logger then
    return
  end
  logger:log(level, vim.inspect(msg), event)
end

---Retrieves the handle of the logger object
---@return table|nil logger handle if found
function Log:get_logger()
  if self.__handle then
    return self.__handle
  end

  local logger = self:init()
  if not logger then
    return
  end

  self.__handle = logger
  return logger
end

---Retrieves the path of the logfile
---@return string path of the logfile
function Log:get_path()
  return string.format("%s/%s.log", get_cache_dir(), "lvim")
end

---Add a log entry at TRACE level
---@param msg any
---@param event any
function Log:trace(msg, event)
  self:add_entry(self.levels.TRACE, msg, event)
end

---Add a log entry at DEBUG level
---@param msg any
---@param event any
function Log:debug(msg, event)
  self:add_entry(self.levels.DEBUG, msg, event)
end

---Add a log entry at INFO level
---@param msg any
---@param event any
function Log:info(msg, event)
  self:add_entry(self.levels.INFO, msg, event)
end

---Add a log entry at WARN level
---@param msg any
---@param event any
function Log:warn(msg, event)
  self:add_entry(self.levels.WARN, msg, event)
end

---Add a log entry at ERROR level
---@param msg any
---@param event any
function Log:error(msg, event)
  self:add_entry(self.levels.ERROR, msg, event)
end

setmetatable({}, Log)

return Log
