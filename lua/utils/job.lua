local M = {}

local log = require("lvim.log")

---
---@param opts Job
---@return Job
function M.create(opts)
  local Job = require("plenary.job")

  local cmd = vim.trim(("%s %s"):format(opts.command, table.concat(opts.args or {}, " "):gsub("%%", "%%%%")))
  log:debug(("Will run job: %s"):format(cmd))

  local job = Job:new(vim.tbl_extend("force", opts, {
    env = vim.tbl_extend("force", vim.fn.environ(), opts.env or {}),
    enabled_recording = true,
    detached = true,
    on_exit = function(j, code)
      vim.schedule(function()
        if code == 0 then
          log:info("Command executed: %s", cmd)

          log:debug("%s -> %s", cmd, vim.inspect(j:result()))

          if opts.on_success then
            opts.on_success(j)
          end
        else
          log:error(("Command failed with exit code %d: %s -> %s"):format(code, cmd, vim.inspect(j:result())))

          if opts.on_failure then
            opts.on_failure(j)
          end
        end
      end)
    end,
  }))

  return job
end

return M
