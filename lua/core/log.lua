local M = {}

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

local queue = {}

function M:set_level(level)
  local logger_ok, _ = xpcall(function()
    local log_level = M.levels[level:upper()]
    local structlog = require("structlog")
    if structlog then
      local logger = structlog.get_logger("core")
      for _, s in ipairs(logger.sinks) do
        s.level = log_level
      end
    end
  end, debug.traceback)

  if not logger_ok then
    M:warn("Unable to set logger's level: " .. debug.traceback())
  end
end

function M:init()
  local status_ok, structlog = pcall(require, "structlog")
  if not status_ok then
    return nil
  end

  local SinkAdapter = require("structlog.sinks.adapter")

  local function notify(log)
    vim.notify(log.msg, log.level)
  end

  local log_level = M.levels[(lvim.log.level):upper() or "WARN"]
  local logger = {
    lvim = {
      pipelines = {
        {
          level = log_level,
          sink = structlog.sinks.RotatingFile(self:get_path(), { max_size = 1048576 * 10 }),
          processors = {
            structlog.processors.StackWriter({ "line", "file" }, { max_parents = 3, stack_level = 2 }),
            structlog.processors.Timestamper("%F %H:%M:%S"),
          },
          formatter = structlog.formatters.Format( --
            "%s [%-5s] %s",
            { "timestamp", "level", "msg" },
            {
              blacklist = { "logger_name" },
            }
          ),
        },
        {
          level = log_level,
          sink = structlog.sinks.Console(),
          processors = {},
          formatter = structlog.formatters.FormatColorizer( --
            "[%-5s] %s",
            { "level", "msg" },
            {
              blacklist = { "logger_name" },
              level = structlog.formatters.FormatColorizer.color_level(),
            }
          ),
        },
        {
          level = M.levels.INFO,
          sink = SinkAdapter(notify),
          processors = {},
          formatter = structlog.formatters.Format( --
            "%s",
            { "msg" },
            { blacklist_all = true }
          ),
        },
      },
    },
  }

  structlog.configure(logger)

  return structlog.get_logger("core")
end

--- Adds a log entry using Plenary.log
---@param msg any
---@param level string [same as vim.log.log_levels]
function M:add_entry(level, msg, ...)
  local logger = self:get_logger()
  if not logger then
    table.insert(queue, { level or vim.log.levels.DEBUG, msg, { ... } })

    return
  end

  logger:log(level, vim.inspect(msg):format(...))
end

---Retrieves the handle of the logger object
---@return table|nil logger handle if found
function M:get_logger()
  if self.__handle then
    return self.__handle
  end

  local logger = self:init()
  if not logger then
    return
  end

  self.__handle = logger

  for _, entry in ipairs(queue) do
    if #entry == 3 then
      M:log(entry[1], entry[2], unpack(entry[3]))
    else
      M:log(entry[1], entry[2])
    end
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
  self:add_entry(level, msg, ...)
end

---Add a log entry at TRACE level
---@param msg any
---@param ... any
function M:trace(msg, ...)
  self:add_entry(self.levels.TRACE, msg, ...)
end

---Add a log entry at DEBUG level
---@param msg any
---@param ... any
function M:debug(msg, ...)
  self:add_entry(self.levels.DEBUG, msg, ...)
end

---Add a log entry at INFO level
---@param msg any
---@param ... any
function M:info(msg, ...)
  self:add_entry(self.levels.INFO, msg, ...)
end

---Add a log entry at WARN level
---@param msg any
---@param ... any
function M:warn(msg, ...)
  self:add_entry(self.levels.WARN, msg, ...)
end

---Add a log entry at ERROR level
---@param msg any
---@param ... any
function M:error(msg, ...)
  self:add_entry(self.levels.ERROR, msg, ...)
end

setmetatable({}, M)

return M
