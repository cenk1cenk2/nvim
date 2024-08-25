local M = {}

---@enum LogLevel
M.levels = {
  [1] = "TRACE",
  [2] = "DEBUG",
  [3] = "INFO",
  [4] = "WARN",
  [5] = "ERROR",
  TRACE = 1,
  DEBUG = 2,
  INFO = 3,
  WARN = 4,
  ERROR = 5,
}

---@class LogQueueEntry
---@field level LogLevel
---@field message any
---@field sprintf table

---@type LogQueueEntry[]
local queue = {}

function M:set_level(level)
  local logger_ok, _ = xpcall(function()
    local log_level = M.levels[level:upper()]
    local sl = require("structlog")
    if sl then
      local logger = sl.get_logger("core")
      if logger == nil then
        error("No logger available.")
      end
      for _, s in ipairs(logger.sinks) do
        s.level = log_level
      end
    end
  end, debug.traceback)

  if not logger_ok then
    M:warn("Unable to set logger's level: %s", debug.traceback())
  end
end

function M:init()
  local ok, sl = pcall(require, "structlog")
  if not ok then
    return nil
  end

  local adapter = require("structlog.sinks.adapter")

  local function notify(log)
    vim.notify(log.msg, log.level)
  end

  local log_level = M.levels[(nvim.log.level):upper() or "WARN"]
  local logger = {
    nvim = {
      pipelines = {
        {
          level = log_level,
          sink = sl.sinks.RotatingFile(self:get_path(), { max_size = 1048576 * 10 }),
          processors = {
            sl.processors.StackWriter({ "line", "file" }, { max_parents = 3, stack_level = 2 }),
            sl.processors.Timestamper("%F %H:%M:%S"),
          },
          formatter = sl.formatters.Format( --
            "%s [%-5s] %s",
            { "timestamp", "level", "msg" },
            {
              blacklist = { "logger_name" },
            }
          ),
        },
        {
          level = log_level,
          sink = sl.sinks.Console(),
          processors = {},
          formatter = sl.formatters.FormatColorizer( --
            "[%-5s] %s",
            { "level", "msg" },
            {
              blacklist = { "logger_name" },
              level = sl.formatters.FormatColorizer.color_level(),
            }
          ),
        },
        {
          level = M.levels.INFO,
          sink = adapter(notify),
          processors = {},
          formatter = sl.formatters.Format( --
            "%s",
            { "msg" },
            { blacklist_all = true }
          ),
        },
      },
    },
  }

  sl.configure(logger)

  return sl.get_logger("nvim")
end

---@param msg any
---@param sprintf? any[]
function M:splat(msg, sprintf)
  sprintf = sprintf or {}

  if type(msg) ~= "string" then
    msg = vim.inspect(msg, { newline = "\n", indent = "  " })
  end

  if #sprintf == 0 then
    return msg
  end

  return msg:format(unpack(vim.tbl_map(function(v)
    if type(v) ~= "string" then
      return vim.inspect(v, { newline = "\n", indent = "  " })
    end

    return v
  end, sprintf)))
end

--- Adds a log entry using Plenary.log
---@param level string [same as vim.log.log_levels]
---@param msg any
---@param sprintf? any[]
function M:write(level, msg, sprintf)
  local logger = self:get()

  if not logger then
    table.insert(queue, {
      level = level or vim.log.levels.DEBUG,
      message = msg,
      sprintf = sprintf,
    })

    return
  end

  return logger:log(level, M:splat(msg, sprintf))
end

---Retrieves the handle of the logger object
---@return table|nil logger handle if found
function M:get()
  if self.__handle then
    return self.__handle
  end

  local logger = self:init()
  if not logger then
    return
  end

  self.__handle = logger

  for _, entry in pairs(queue) do
    logger:log(entry.level, M:splat(entry.message, entry.sprintf))
  end
  queue = {}

  return logger
end

---Retrieves the path of the logfile
---@return string path of the logfile
function M:get_path()
  return string.format("%s/%s.log", get_cache_dir(), "core")
end

---Add a log entry at TRACE level
---@param msg any
---@param ... any
function M:log(level, msg, ...)
  self:write(level, msg, { ... })
end

---Add a log entry at TRACE level
---@param msg any
---@param ... any
function M:trace(msg, ...)
  self:write(self.levels.TRACE, msg, { ... })
end

---Add a log entry at DEBUG level
---@param msg any
---@param ... any
function M:debug(msg, ...)
  self:write(self.levels.DEBUG, msg, { ... })
end

---Add a log entry at INFO level
---@param msg any
---@param ... any
function M:info(msg, ...)
  self:write(self.levels.INFO, msg, { ... })
end

---Add a log entry at WARN level
---@param msg any
---@param ... any
function M:warn(msg, ...)
  self:write(self.levels.WARN, msg, { ... })
end

---Add a log entry at ERROR level
---@param msg any
---@param ... any
function M:error(msg, ...)
  self:write(self.levels.ERROR, msg, { ... })
end

setmetatable({}, M)

return M
