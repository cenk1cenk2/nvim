local M = {}

local Log = require("lvim.core.log")

function M.spawn(opts)
  local Job = require("plenary.job")

  Log:debug(("Will run job: %s %s"):format(opts.command, table.concat(opts.args or {}, " ")))

  local job = Job:new(vim.tbl_extend("force", opts, {
    env = vim.tbl_extend("force", vim.fn.environ(), opts.env or {}),
    enabled_recording = true,
    detached = true,
    on_exit = function(j, code)
      if code ~= 0 then
        Log:error(("Command %s exited with exit code %s: %s"):format(opts.command, code, vim.inspect(j:stderr_result())))

        return
      end

      Log:info(("Command %s executed."):format(opts.command))

      Log:debug(vim.inspect(j:result()))
    end,
  }))

  job:sync(5000)

  if job.code == 0 and opts.on_success then
    opts.on_success(job)
  end

  if job.code ~= 0 and opts.on_failure then
    opts.on_failure(job)
  end

  return job
end

return M
