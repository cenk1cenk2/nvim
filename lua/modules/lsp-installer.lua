local _, path = pcall(require, "nvim-lsp-installer.core.path")
local _, platform = pcall(require, "nvim-lsp-installer.core.platform")

local M = {}

---@param root_dir string @The directory to resolve the executable from.
---@param executable string
function M.go_executable(root_dir, executable)
  return path.concat { root_dir, executable }
end

---@param root_dir string @The directory to resolve the executable from.
---@param executable string
function M.npm_executable(root_dir, executable)
  return path.concat {
    root_dir,
    "node_modules",
    ".bin",
    platform.is_win and ("%s.cmd"):format(executable) or executable,
  }
end

local REL_INSTALL_DIR = "venv"

---@param root_dir string @The directory to resolve the executable from.
---@param executable string
function M.pip3_executable(root_dir, executable)
  return path.concat { root_dir, REL_INSTALL_DIR, platform.is_win and "Scripts" or "bin", executable }
end

---@param root_dir string @The directory to resolve the executable from.
---@param executable string
function M.gem_executable(root_dir, executable)
  return path.concat { root_dir, "bin", executable }
end

function M.executable(root_dir, executable)
  return path.concat { root_dir, executable }
end

M.setup = function() end

return M
