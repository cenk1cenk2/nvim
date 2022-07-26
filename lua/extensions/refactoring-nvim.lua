local M = {}

local extension_name = "refactoring_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      visual_mode = {
        ["re"] = {
          [[<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
          { desc = "extract to function" },
        },
        ["rf"] = {
          [[<Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
          { desc = "extract function to file" },
        },
        ["rv"] = {
          [[<Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
          { desc = "extract variable" },
        },
        ["ri"] = {
          [[<Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
          { desc = "inline variable" },
        },
      },
    },
    setup = {},
  }
end

function M.setup()
  require("refactoring").setup(lvim.extensions[extension_name].setup)

  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
