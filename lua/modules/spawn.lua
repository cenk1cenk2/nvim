local Log = require "lvim.core.log"
local uv = vim.loop

local M = {}

function M.run_command(cmd, opts)
  local handle, pid_or_err
  handle, pid_or_err = uv.spawn(cmd, opts, function(exit_code, signal)
    local successful = exit_code == 0 and signal == 0

    if successful then
      Log:info(("Command has finished: %s"):format(cmd))
    else
      Log:error(("Command %s exited with error %s exit_code=%s, signal=%s"):format(cmd, pid_or_err, exit_code, signal))
    end

    handle:close()
  end)

  if handle == nil then
    if type(pid_or_err) == "string" and pid_or_err:find "ENOENT" == 1 then
      Log:error(("Could not find executable %q in path."):format(cmd))
    else
      Log:error(("Failed to spawn process cmd=%s err=%s"):format(cmd, pid_or_err))
    end
  end
end

M.setup = function() end

return M
