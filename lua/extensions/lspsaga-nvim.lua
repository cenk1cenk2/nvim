local M = {}

local extension_name = "lspsaga_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      -- Error,Warn,Info,Hint
      diagnostic_header = { " ", " ", " ", "ﴞ " },
      -- show diagnostic source
      show_diagnostic_source = true,
      -- add bracket or something with diagnostic source,just have 2 elements
      diagnostic_source_bracket = { "[", "]" },
      -- use emoji lightbulb in default
      code_action_icon = "💡",
      -- if true can press number to execute the codeaction in codeaction window
      code_action_num_shortcut = true,
      -- same as nvim-lightbulb but async
      code_action_lightbulb = {
        enable = true,
        sign = true,
        sign_priority = 20,
        virtual_text = true,
      },
      -- preview lines of lsp_finder and definition preview
      max_preview_lines = 10,
      finder_action_keys = {
        open = "o",
        vsplit = "s",
        split = "i",
        quit = "q",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>", -- quit can be a table
      },
      code_action_keys = {
        quit = "q",
        exec = "<CR>",
      },
      rename_action_quit = "<C-c>",
      -- "single" "double" "rounded" "bold" "plus"
      border_style = "single",
      -- if you don't use nvim-lspconfig you must pass your server name and
      -- the related filetypes into this table
      -- like server_filetype_map = {metals = {'sbt', 'scala'}}
      server_filetype_map = {},
    },
  }
end

function M.setup()
  local extension = require "lspsaga"

  extension.init_lsp_saga(lvim.extensions[extension_name].setup)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
