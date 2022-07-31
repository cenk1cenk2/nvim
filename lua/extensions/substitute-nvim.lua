local M = {}

local extension_name = "substitute_nvim"

function M.config()
  lvim.extensions[extension_name] = { active = true, on_config_done = nil }

  local status_ok, substitute = pcall(require, "substitute")
  if not status_ok then
    return
  end

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], {
    keymap = {
      normal_mode = {
        ["sd"] = { substitute.operator, { desc = "substitute operator" } },
        ["sds"] = { substitute.line, { desc = "substitute line" } },
        ["sdd"] = { substitute.eol, { desc = "substitute eol" } },
      },
      visual_mode = { ["sd"] = { [[:lua require('substitute').visual()<cr>]] }, { desc = "substitute visual" } },
    },
    setup = {
      on_substitute = nil,
      yank_substitued_text = false,
      range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        motion1 = false,
        motion2 = false,
      },
      exchange = {
        motion = false,
      },
    },
  })
end

function M.setup()
  local extension = require "substitute"

  extension.setup(lvim.extensions[extension_name].setup)

  require("lvim.keymappings").load(lvim.extensions[extension_name].keymap)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
