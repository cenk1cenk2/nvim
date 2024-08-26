-- https://github.com/wallpants/github-preview.nvim
local M = {}

M.name = "wallpants/github-preview.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "wallpants/github-preview.nvim",
        cmd = { "GithubPreviewToggle" },
      }
    end,
    setup = function()
      ---@type github_preview_config
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
          color = nvim.ui.colors.gray[300],
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
    on_setup = function(c)
      require("github-preview").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "M" }),
          function()
            vim.cmd([[GithubPreviewToggle]])
          end,
          desc = "toggle markdown preview in browser",
        },
      }
    end,
  })
end

return M
