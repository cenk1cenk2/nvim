local M = {}

---Completion string for `vim.ui.input` that completes the flags of a command parsed from its `--help` output.
---@param command string
---@return string
function M.flags_for(command)
  return ("customlist,v:lua.require'ck.modules.completion'.flags.%s"):format(command)
end

---@type table<string, fun(arglead: string): string[]>
M.flags = setmetatable({}, {
  __index = function(t, command)
    local flags

    local complete = function(arglead)
      if not flags then
        flags = M.parse_flags(vim.fn.systemlist({ command, "--help" }))
      end

      if arglead == "" then
        return flags
      end

      return vim.fn.matchfuzzy(flags, arglead)
    end

    rawset(t, command, complete)

    return complete
  end,
})

---@param lines string[]
---@return string[]
function M.parse_flags(lines)
  local flags = {}
  local seen = {}

  for _, line in ipairs(lines) do
    local definition = line:match("^%s+(%-.-)%s%s") or line:match("^%s+(%-.*)$")

    if definition then
      for flag in definition:gmatch("%-%-?%w[%w%-]*") do
        if not seen[flag] then
          seen[flag] = true
          table.insert(flags, flag)
        end
      end
    end
  end

  return flags
end

return M
