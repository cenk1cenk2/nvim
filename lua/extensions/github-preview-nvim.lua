-- https://github.com/wallpants/github-preview.nvim
local M = {}

local extension_name = "wallpants/github-preview.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "wallpants/github-preview.nvim",
        cmd = { "GithubPreviewToggle" },
      }
    end,
    setup = function()
      return {
        -- these are the default values,
        -- any values you specify will be merged with this dictionary

        host = "localhost",

        port = 6041,

        -- set to "true" to force single-file mode & disable repository mode
        single_file = true,

        theme = {
          -- "system" | "light" | "dark"
          name = "dark",
          high_contrast = false,
        },

        -- define how to render <details> tags on init/content-change
        -- true: <details> tags are rendered open
        -- false: <details> tags are rendered closed
        details_tags_open = true,

        cursor_line = {
          disable = false,

          -- CSS color
          -- if you provide an invalid value, cursorline will be invisible
          color = lvim.ui.colors.grey[300],
          opacity = 0.2,
        },

        scroll = {
          disable = false,

          -- Between 0 and 100
          -- VERY LOW and VERY HIGH numbers might result in cursorline out of screen
          top_offset_pct = 35,
        },

        -- for debugging
        -- nil | "debug" | "verbose"
        log_level = nil,
      }
    end,
    on_setup = function(config)
      require("github-preview").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          ["m"] = { ":GithubPreviewToggle<CR>", "toggle markdown preview" },
        },
      }
    end,
  })
end

return M
