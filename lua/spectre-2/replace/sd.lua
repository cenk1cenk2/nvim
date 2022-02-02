local Job = require "plenary.job"
local log = require "spectre._log"

local sd = {}

sd.init = function(_, config)
  config = vim.tbl_extend("force", {
    cmd = "sd",
    find = "%s",
    replace = "%s",
  }, config or {})

  return config
end

sd.replace = function(self, value)
  local find = self.state.find
  local replace = self.state.replace

  if self.state.options_value ~= nil then
    for _, v in pairs(self.state.options_value) do
      table.insert(self.state.args, v)
    end
  end

  local t_search = string.format(find, value.search_text)
  local t_replace = string.format(replace, value.replace_text)

  local args = vim.tbl_flatten {
    self.state.args,
    t_search,
    t_replace,
    value.filename,
  }

  log.debug("replace cwd " .. (value.cwd or ""))
  log.debug("replace cmd: " .. self.state.cmd .. " " .. table.concat(args, " "))

  if value.cwd == "" then
    value.cwd = nil
  end

  local job = Job:new {
    command = self.state.cmd,
    cwd = value.cwd,
    args = args,
    on_stdout = function(_, v)
      self:on_output(v, value)
    end,
    on_stderr = function(_, v)
      self:on_error(v, value)
    end,
    on_exit = function(_, v)
      self:on_exit(v, value)
    end,
  }

  job:sync()
end

return sd
