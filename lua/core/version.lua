local M = {}

local log = require("core.log")
local job = require("utils.job")

function M.update_repository()
  log:info("Checking for updates...")

  job
    .create({
      command = "git",
      args = {
        "fetch",
        "--all",
      },
      cwd = get_config_dir(),
    })
    :sync(5000)

  local _, code = job
    .create({
      command = "git",
      args = {
        "diff",
        "@{upstream}",
        "--quiet",
      },
      cwd = get_config_dir(),
      no_log_failure = true,
    })
    :sync(5000)

  if code == 0 then
    log:info("Configuration is already up-to-date.")

    return
  end

  job
    .create({
      command = "git",
      args = {
        "merge",
        "--ff-only",
        "--progress",
      },
      cwd = get_config_dir(),
      on_success = function(j)
        log:info("Finished update:\n%s", table.concat(j:result(), "\n"))
      end,
    })
    :sync(5000)
end

---Get the current neovim development branch
---@return string|nil
function M.get_config_branch()
  local stdout, code = job
    .create({
      command = "git",
      args = {
        "rev-parse",
        "--abbrev-ref",
        "HEAD",
      },
      cwd = get_config_dir(),
    })
    :sync(5000)

  if code > 0 and #stdout == 0 then
    return
  end

  return unpack(stdout)
end

---Get currently checked-out tag of neovim
---@return string
function M.get_config_tag()
  local stdout, code = job
    .create({
      command = "git",
      args = {
        "describe",
        "--tags",
        "--abbrev=0",
      },
      cwd = get_config_dir(),
    })
    :sync(5000)

  if code > 0 and #stdout == 0 then
    return
  end

  return unpack(stdout)
end

---Get the commit hash of currently checked-out commit of neovim
---@return string|nil
function M.get_config_sha()
  local stdout, code = job
    .create({
      command = "git",
      args = {
        "log",
        "--pretty=format:%h",
        "-1",
      },
      cwd = get_config_dir(),
    })
    :sync(5000)

  if code > 0 and #stdout == 0 then
    return
  end

  return unpack(stdout)
end

---Get currently running version of neovim
---@return string
function M.get_config_version()
  local current_branch = M.get_config_branch()

  if current_branch ~= "HEAD" or "" then
    return ("%s-%s"):format(current_branch, M.get_config_sha())
  else
    return ("v%s"):format(M.get_config_tag())
  end
end

---Get currently installed version of neovim
---@return string
function M.get_nvim_version()
  local stdout, code = job
    .create({
      command = "nvim",
      args = { "--version" },
    })
    :sync(5000)

  if code > 0 and #stdout == 0 then
    return
  end

  return unpack(stdout)
end

return M
