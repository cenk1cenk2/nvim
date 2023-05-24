-- https://github.com/kevinhwang91/nvim-ufo
local M = {}

local extension_name = "nvim_ufo"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "BufReadPost",
      }
    end,
    inject_to_configure = function()
      return {
        handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = ("  %s %d "):format(lvim.ui.icons.ui.ArrowCircleDown, endLnum - lnum)
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
        open_fold_hl_timeout = 100,
        close_fold_kinds = {},
        -- close_fold_kinds = { "imports", "comment" },
        preview = {
          win_config = {
            border = lvim.ui.border,
            winhighlight = "Normal:Normal",
            winblend = 0,
          },
          mappings = {
            scrollU = "<C-u>",
            scrollD = "<C-d>",
          },
        },
        provider_selector = function(bufnr, filetype, buftype)
          -- if vim.tbl_contains({ "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte", "go" }, filetype) then
          --   return
          -- end

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
      vim.o.foldmethod = "manual"

      -- local original = lvim.lsp.wrapper.hover
      --
      -- lvim.lsp.wrapper.hover = function()
      --   local winid = require("ufo").peekFoldedLinesUnderCursor()
      --
      --   if not winid then
      --     original()
      --   end
      -- end
    end,
    keymaps = function()
      return {
        {
          { "n", "v" },
          ["zR"] = {
            function()
              require("ufo").openAllFolds()
            end,
            { desc = "open all folds - ufo" },
          },
          ["zM"] = {
            function()
              require("ufo").closeAllFolds()
            end,
            { desc = "close all folds - ufo" },
          },
          ["zr"] = {
            function()
              require("ufo").openFoldsExceptKinds()
            end,
            { desc = "open fold - ufo" },
          },
          ["zm"] = {
            function()
              require("ufo").closeFoldsWith()
            end,
            { desc = "close fold - ufo" },
          },
        },
      }
    end,
  })
end

return M
