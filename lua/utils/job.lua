local M = {}

---@module "plenary.job"

local log = require("core.log")

---@class CommandJob: Job
---@field on_success? function (j: Job): nil
---@field on_failure? function (j: Job): nil
---@field no_log_success? boolean
---@field no_log_failure? boolean

--- Creates a command job through plenary.
---@param command CommandJob
---@return Job
function M.create(command)
  local Job = require("plenary.job")

  local cmd = vim.trim(("%s %s"):format(command.command, table.concat(command.args or {}, " "):gsub("%%", "%%%%")))
  log:debug(("Will run job: %s"):format(cmd))

  local job = Job:new(vim.tbl_extend("force", command, {
    env = vim.tbl_extend("force", vim.fn.environ(), command.env or {}),
    enabled_recording = true,
    detached = true,
    on_exit = function(j, code)
      vim.schedule(function()
        if code == 0 then
          if not command.no_log_success then
            log:info("Command executed: %s", cmd)

            log:debug("%s -> %s", cmd, vim.inspect(j:result()))
          end

          if command.on_success then
            command.on_success(j)
          end
        else
          if not command.no_log_failure then
            log:error(("Command failed with exit code %d: %s -> %s"):format(code, cmd, vim.inspect(j:result())))
          end

          if command.on_failure then
            command.on_failure(j)
          end
        end
      end)
    end,
  }))

  return job
end

return M
