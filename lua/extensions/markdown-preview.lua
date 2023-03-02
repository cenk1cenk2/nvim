-- https://github.com/iamcco/markdown-preview.nvim
local M = {}

local extension_name = "markdown_preview"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "iamcco/markdown-preview.nvim",
        build = function()
          vim.cmd([[call mkdp#util#install()]])
        end,
        cmd = { "MarkdownPreview" },
        ft = { "markdown" },
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
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          ["m"] = { ":MarkdownPreview<CR>", "start markdown preview" },
          ["M"] = { ":MarkdownPreviewStop<CR>", "stop markdown preview" },
        },
      }
    end,
  })
end

return M
