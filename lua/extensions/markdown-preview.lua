-- https://github.com/iamcco/markdown-preview.nvim

local setup = require "utils.setup"

local M = {}

local extension_name = "markdown_preview"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "iamcco/markdown-preview.nvim",
        run = { "cd app & yarn & yarn add -D tslib", ":call mkdp#util#install()" },
        config = function()
          require("utils.setup").packer_config "markdown_preview"
        end,
        disable = not config.active,
      }
    end,
    legacy_setup = {
      mkdp_echo_preview_url = 1,
      mkdp_open_to_the_world = 1,
      mkdp_auto_close = 0,
      mkdp_theme = "dark",
      mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = true,
      },
      mkdp_port = "15000",
      mkdp_page_title = "${name} - preview",
    },
    wk = {
      ["a"] = {
        ["m"] = { ":MarkdownPreview<CR>", "markdown preview start" },
        ["M"] = { ":MarkdownPreviewStop<CR>", "markdown preview stop" },
      },
    },
  })
end

return M
