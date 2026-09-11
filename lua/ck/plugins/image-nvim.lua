-- https://github.com/3rd/image.nvim
local M = {}

M.name = "3rd/image.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "3rd/image.nvim",
        -- the default build step compiles the magick luarock, which the `magick_cli` processor does not need
        build = false,
        ft = { "markdown", "vimwiki", "norg", "rst", "typst", "asciidoc" },
        event = {
          {
            event = { "BufReadPre" },
            pattern = M.image_patterns,
          },
        },
      }
    end,
    setup = function()
      return {
        backend = "kitty",
        processor = "magick_cli",
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = true,
            download_remote_images = true,
            filetypes = { "markdown", "vimwiki" },
          },
        },
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = vim.list_extend(vim.deepcopy(nvim.disabled_filetypes), {
          "blink-cmp-menu",
          "blink-cmp-documentation",
          "noice",
          "snacks_notif",
          "snacks_win_backdrop",
        }),
        editor_only_render_when_focused = true,
        -- needs `set -g visual-activity off` in the tmux configuration to not flag every render as activity
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = M.image_patterns,
      }
    end,
    on_setup = function(c)
      require("image").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "i" }),
          function()
            local image = require("image")

            if image.is_enabled() then
              image.disable()
            else
              image.enable()
            end
          end,
          desc = "toggle inline images",
        },
      }
    end,
  })
end

M.image_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }

return M
