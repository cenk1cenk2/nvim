-- https://github.com/felpafel/inlay-hint.nvim
local M = {}

M.name = "felpafel/inlay-hint.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "felpafel/inlay-hint.nvim",
        event = "LspAttach",
      }
    end,
    setup = function()
      return {
        -- Position of virtual text. Possible values:
        -- 'eol': right after eol character (default).
        -- 'right_align': display right aligned in the window.
        -- 'inline': display at the specified column, and shift the buffer
        -- text to the right as needed.
        virt_text_pos = nvim.lsp.inlay_hints.mode,
        -- Can be supplied either as a string or as an integer,
        -- the latter which can be obtained using |nvim_get_hl_id_by_name()|.
        highlight_group = "LspInlayHint",
        -- Control how highlights are combined with the
        -- highlights of the text.
        -- 'combine': combine with background text color. (default)
        -- 'replace': only show the virt_text color.
        hl_mode = "combine",
        -- line_hints: array with all hints present in current line.
        -- options: table with this plugin configuration.
        -- bufnr: buffer id from where the hints come from.
      }
    end,
    on_setup = function(c)
      require("inlay-hint").setup(c)
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(bufnr)
          return {
            wk = function(_, categories, fn)
              ---@type WKMappings
              return {
                fn.wk_keystroke({ categories.LSP, "T" }),
                function()
                  vim.ui.select({ "eol", "inline", "right_align" }, {
                    prompt = "Inlay Hint Mode",
                  }, function(mode)
                    if not mode then
                      return
                    end

                    nvim.lsp.inlay_hints.mode = mode

                    local setup = require("ck.setup")
                    setup.configure(setup.get_config(M.name), {
                      function(c)
                        c.virt_text_pos = nvim.lsp.inlay_hints.mode

                        return c
                      end,
                    })
                  end)
                end,
                desc = "change inlay hint mode",
                buffer = bufnr,
              }
            end,
          }
        end),
      }
    end,
  })
end

return M
