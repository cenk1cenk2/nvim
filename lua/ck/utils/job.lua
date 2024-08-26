local M = {}

---@module "plenary.job"

local log = require("ck.log")

---@class CommandJob: Job
---@field on_success? function (j: Job): nil
---@field on_failure? function (j: Job): nil
---@field log_callback? log_callback

---@class log_callback
---@field no_success? boolean
---@field no_failure? boolean

--- Creates a command job through plenary.
---@param command CommandJob
---@return Job
function M.create(command)
  ---@type CommandJob
  command = vim.tbl_deep_extend("force", {
    log_callback = {
      no_success = true,
      no_failure = false,
    },
  }, command)

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
          if not command.log_callback.no_success then
            log:info("Command executed: %s", cmd)

            log:debug("%s -> %s", cmd, j:result())
          end

          if command.on_success then
            command.on_success(j)
          end
        else
          if not command.log_callback.no_failure then
            log:error("Command failed with exit code %d: %s -> %s", code, cmd, j:result())
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
