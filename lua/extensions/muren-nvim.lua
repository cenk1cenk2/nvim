-- https://github.com/AckslD/muren.nvim
local M = {}

local extension_name = "muren_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "AckslD/muren.nvim",
      }
    end,
    setup = function()
      return {
        -- general
        create_commands = true,
        filetype_in_preview = true,
        -- default togglable options
        two_step = false,
        all_on_line = true,
        preview = true,
        cwd = false,
        files = "**/*",
        -- keymaps
        keys = {
          close = "q",
          toggle_side = "<Tab>",
          toggle_options_focus = "<C-s>",
          toggle_option_under_cursor = "<CR>",
          scroll_preview_up = "<Up>",
          scroll_preview_down = "<Down>",
          do_replace = "<CR>",
        },
        -- ui sizes
        patterns_width = 30,
        patterns_height = 10,
        options_width = 20,
        preview_height = 12,
        -- options order in ui
        order = {
          "buffer",
          "dir",
          "files",
          "two_step",
          "all_on_line",
          "preview",
        },
        -- highlights used for options ui
        hl = {
          options = {
            on = "@string",
            off = "@variable.builtin",
          },
          preview = {
            cwd = {
              path = "Comment",
              lnum = "Number",
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("muren").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        -- find and replace
        [categories.SEARCH] = {
          m = {
            function()
              require("muren.api").toggle_ui()
            end,
            "toggle muren",
          },
        },
      }
    end,
  })
end

return M
