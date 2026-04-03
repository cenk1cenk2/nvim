-- https://github.com/OXY2DEV/markview.nvim
local M = {}

M.name = "OXY2DEV/markview.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "OXY2DEV/markview.nvim",
        ft = {
          "markdown",
          "rmd",
          "norg",
          "org",
          "vimwiki",
          "Avante",
          "codecompanion",
        },
      }
    end,
    setup = function()
      return {
        preview = {
          max_buf_lines = 250,
          draw_range = { vim.o.lines, vim.o.lines },
          debounce = 150,
          modes = { "n", "no", "c" }, -- Change these modes
          hybrid_modes = { "n", "v", "x" },
          filetypes = {
            "markdown",
            "rmd",
            "norg",
            "org",
            "vimwiki",
            "Avante",
            "codecompanion",
          },
          ignore_buftypes = {},
          condition = function(bufnr)
            local ft = vim.bo[bufnr].ft
            local bt = vim.bo[bufnr].bt

            if bt == "nofile" and vim.tbl_contains({ "codecompanion", "Avante" }, ft) then
              return true
            elseif bt == "nofile" then
              return false
            end
          end,
        },
        markdown = {
          code_blocks = {
            ["diff"] = {
              block_hl = function(_, line)
                if line:match("^%+") then
                  return "MarkviewDiffAdd"
                elseif line:match("^%-") then
                  return "MarkviewDiffDelete"
                elseif line:match("^@@") then
                  return "MarkviewDiffChange"
                else
                  return "MarkviewCode"
                end
              end,
              pad_hl = "MarkviewCode",
            },
          },
          headings = {
            enable = true,
            shift_width = 0,
            shift_char = "",
            heading_1 = {
              hl = "@markup.heading.1.markdown",
            },
            heading_2 = {
              hl = "@markup.heading.2.markdown",
            },
            heading_3 = {
              hl = "@markup.heading.3.markdown",
            },
            heading_4 = {
              hl = "@markup.heading.4.markdown",
            },
            heading_5 = {
              hl = "@markup.heading.5.markdown",
            },
            heading_6 = {
              hl = "@markup.heading.6.markdown",
            },
          },
          list_items = {
            enable = true,
            shift_width = 2,
          },
        },
      }
    end,
    on_setup = function(c)
      require("markview").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "m" }),
          function()
            require("markview").commands.toggle()
          end,
          desc = "toggle markdown preview",
        },
      }
    end,
  })
end

return M

