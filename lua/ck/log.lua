local M = {}

M.name = "ck"

---@enum LogLevel
M.levels = {
  TRACE = 1,
  DEBUG = 2,
  INFO = 3,
  WARN = 4,
  ERROR = 5,
  [vim.log.levels.TRACE] = 1,
  [vim.log.levels.DEBUG] = 2,
  [vim.log.levels.INFO] = 3,
  [vim.log.levels.WARN] = 4,
  [vim.log.levels.ERROR] = 5,
}

---@enum NvimLogLevel
M.nvim_levels = {
  TRACE = vim.log.levels.TRACE,
  DEBUG = vim.log.levels.DEBUG,
  INFO = vim.log.levels.INFO,
  WARN = vim.log.levels.WARN,
  ERROR = vim.log.levels.ERROR,
  [M.levels.TRACE] = vim.log.levels.TRACE,
  [M.levels.DEBUG] = vim.log.levels.DEBUG,
  [M.levels.INFO] = vim.log.levels.INFO,
  [M.levels.WARN] = vim.log.levels.WARN,
  [M.levels.ERROR] = vim.log.levels.ERROR,
}

---@type table<LogLevel, string>
local level_names = {
  [M.levels.TRACE] = "TRACE",
  [M.levels.DEBUG] = "DEBUG",
  [M.levels.INFO] = "INFO",
  [M.levels.WARN] = "WARN",
  [M.levels.ERROR] = "ERROR",
}

---@type table<LogLevel, string>
local writers = {
  [M.levels.TRACE] = "trace",
  [M.levels.DEBUG] = "debug",
  [M.levels.INFO] = "info",
  [M.levels.WARN] = "warn",
  [M.levels.ERROR] = "error",
}

---@type table<NvimLogLevel, string>
local nvim_level_names = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}

---Formats a log entry, attributing it to the first caller outside this module.
---@param min_level NvimLogLevel
---@param level NvimLogLevel
---@return string?
local function format_func(min_level, level, ...)
  if level < min_level then
    return nil
  end

  local depth = 3
  local caller = debug.getinfo(depth, "Sl")
  while caller and caller.short_src:find("ck/log%.lua$") do
    depth = depth + 1
    caller = debug.getinfo(depth, "Sl")
  end

  local parts = {
    ("[%-5s][%s] %s:%s"):format(nvim_level_names[level], os.date("%F %H:%M:%S"), caller.short_src, caller.currentline),
  }
  for i = 1, select("#", ...) do
    table.insert(parts, tostring((select(i, ...))))
  end

  return table.concat(parts, "\t") .. "\n"
end

--- Sets the log level.
---@param level LogLevel
function M:set_log_level(level)
  xpcall(function()
    local previous = nvim.log.level
    nvim.log.level = level

    if self:to_level(level) ~= self:to_level(previous) then
      self:info("Set log level: %s", level)
    else
      self:debug("Set log level to default: %s", level)
    end
  end, debug.traceback)
end

---@param level LogLevel
---@return integer
function M:to_level(level)
  return self.levels[tostring(level):upper()]
end

---@return integer
function M:to_nvim_level()
  return self.nvim_levels[tostring(nvim.log.level):upper()]
end

---Retrieves the handle of the logger instance, creating it on first use and
---keeping its level in sync with the configured one.
---@return vim.Log
function M:get_logger()
  if not self.__handle then
    self.__handle = vim.log.new({
      name = self.name,
      format_func = format_func,
    })
  end

  vim.log.set_level(self.__handle, self:to_nvim_level())

  return self.__handle
end

---@param msg any
---@param sprintf? any[]
---@return string
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

---Adds a log entry using vim.log
---@param level LogLevel
---@param message any
---@param sprintf? any[]
function M:write(level, message, sprintf)
  local logger = self:get_logger()
  local splatted = self:splat(message, sprintf)

  logger[writers[level]](splatted)

  if is_headless() then
    if self.nvim_levels[level] >= vim.log.get_level(logger) then
      print(("[%-5s] %s"):format(level_names[level], splatted))
    end
  elseif level >= self.levels.INFO then
    vim.notify(splatted, self.nvim_levels[level])
  end
end

---Retrieves the path of the logfile
---@return string
function M:get_log_filepath()
  return vim.fs.joinpath(vim.fn.stdpath("log"), self.name:lower() .. ".log")
end

---Retrieves the path of the neovim logfile.
---@return string
function M:get_nvim_logfile_path()
  return os.getenv("NVIM_LOG_FILE") or "/tmp/nvim-session.log"
end

---Truncates a logfile.
---@param path string
function M:truncate_logfile(path)
  local fd, _, err = vim.uv.fs_open(path, "w+", 644)

  if err then
    self:error("Failed to truncate log file: %s", err)

    return
  end

  vim.uv.fs_close(fd)
  self:info("Truncated log file: %s", require("ck.utils.fs").get_relative_to_home(path))
end

---Add a log entry at given level.
---@param level LogLevel
---@param message any
---@param ... any
function M:log(level, message, ...)
  self:write(level, message, { ... })
end

---Add a log entry at TRACE level.
---@param message any
---@param ... any
function M:trace(message, ...)
  self:write(self.levels.TRACE, message, { ... })
end

---Add a log entry at DEBUG level.
---@param message any
---@param ... any
function M:debug(message, ...)
  self:write(self.levels.DEBUG, message, { ... })
end

---Add a log entry at INFO level.
---@param message any
---@param ... any
function M:info(message, ...)
  self:write(self.levels.INFO, message, { ... })
end

---Add a log entry at WARN level.
---@param message any
---@param ... any
function M:warn(message, ...)
  self:write(self.levels.WARN, message, { ... })
end

---Add a log entry at ERROR level.
---@param message any
---@param ... any
function M:error(message, ...)
  self:write(self.levels.ERROR, message, { ... })
end

setmetatable({}, M)

return M
