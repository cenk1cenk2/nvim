-- https://github.com/kevinhwang91/nvim-ufo
local M = {}

local extension_name = "nvim_ufo"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "kevinhwang91/nvim-ufo",
        requires = { "kevinhwang91/promise-async" },
        config = function()
          require("utils.setup").packer_config "nvim_ufo"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        ufo = require "ufo",
        handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = ("   %d "):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- str width returned from truncate() may less than 2nd argument, need padding
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, "MoreMsg" })
          return newVirtText
        end,
      }
    end,
    setup = function(config)
      return {
        open_fold_hl_timeout = 0,
        -- close_fold_kinds = { "imports", "comment" },
        preview = {
          win_config = {
            border = { "", "─", "", "", "", "─", "", "" },
            winhighlight = "Normal:Folded",
            winblend = 0,
          },
          mappings = {
            scrollU = "<C-u>",
            scrollD = "<C-d>",
          },
        },
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
        fold_virt_text_handler = config.inject.handler,
      }
    end,
    on_setup = function(config)
      require("ufo").setup(config.setup)
    end,
    on_done = function()
      -- vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- vim.o.foldexpr = "manual"

      local original = lvim.lsp_wrapper.hover

      lvim.lsp_wrapper.hover = function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          original()
        end
      end
    end,
    keymaps = function(config)
      local ufo = config.inject.ufo

      return {
        n = {
          ["zR"] = { ufo.openAllFolds, { desc = "open all folds - ufo" } },
          ["zM"] = { ufo.closeAllFolds, { desc = "close all folds - ufo" } },
          ["zr"] = { ufo.openFoldsExceptKinds, { desc = "open fold - ufo" } },
          ["zm"] = { ufo.closeFoldsWith, { desc = "close fold - ufo" } },
        },
        v = {
          ["zR"] = { ufo.openAllFolds, { desc = "open all folds - ufo" } },
          ["zM"] = { ufo.closeAllFolds, { desc = "close all folds - ufo" } },
          ["zr"] = { ufo.openFoldsExceptKinds, { desc = "open fold - ufo" } },
          ["zm"] = { ufo.closeFoldsWith, { desc = "close fold - ufo" } },
        },
      }
    end,
  })
end

return M
