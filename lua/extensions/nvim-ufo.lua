-- https://github.com/kevinhwang91/nvim-ufo
local M = {}

M.name = "kevinhwang91/nvim-ufo"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        -- https://github.com/kevinhwang91/nvim-ufo/issues/235
        -- event = "BufReadPre",
        lazy = false,
      }
    end,
    setup = function()
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
        enable_get_fold_virt_text = true,
        fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate, ctx)
          local result = {}
          vim.list_extend(result, M.chunker(virt_text, width, truncate))

          table.insert(result, { (" %s "):format(lvim.ui.icons.ui.Ellipsis), "MoreMsg" })

          local end_text = ctx.get_fold_virt_text(end_lnum)
          for index, value in ipairs(end_text) do
            -- strip the indentations of the first encounter then break out for the next spaces
            if type(value) == "table" and vim.trim(value[1]) == "" then
              table.remove(end_text, index)
            elseif type(value) == "string" and vim.trim(value) == "" then
              table.remove(end_text, index)
            else
              break
            end
          end

          vim.list_extend(result, M.chunker(end_text, width, truncate))
          table.insert(result, { (" %s %d "):format(lvim.ui.icons.ui.Expand, end_lnum - lnum), "MoreMsg" })

          return result
        end,
      }
    end,
    on_setup = function(c)
      require("ufo").setup(c)
    end,
    on_done = function()
      -- vim.o.foldcolumn = "1"
      vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
      vim.opt.foldmethod = "manual"

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
          "zR",
          function()
            require("ufo").openAllFolds()
          end,
          desc = "open all folds - ufo",
          mode = { "n", "v", "x" },
        },
        {
          "zM",
          function()
            require("ufo").closeAllFolds()
          end,
          desc = "close all folds - ufo",
          mode = { "n", "v", "x" },
        },
        {
          "zr",
          function()
            require("ufo").openFoldsExceptKinds()
          end,
          desc = "open fold - ufo",
          mode = { "n", "v", "x" },
        },
        {

          "zm",
          function()
            require("ufo").closeFoldsWith()
          end,
          desc = "close fold - ufo",
          mode = { "n", "v", "x" },
        },
      }
    end,
  })
end

function M.chunker(virt_text, target_width, truncate)
  local result = {}
  local cursor_width = 0
  local suffix

  for _, chunk in ipairs(virt_text) do
    local chunk_text = chunk[1]
    local chunk_width = vim.fn.strdisplaywidth(chunk_text)

    if target_width > cursor_width + chunk_width then
      table.insert(result, chunk)
    else
      chunk_text = truncate(chunk_text, target_width - cursor_width)
      local hl_group = chunk[2]
      table.insert(result, { chunk_text, hl_group })
      chunk_width = vim.fn.strdisplaywidth(chunk_text)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if cursor_width + chunk_width < target_width then
        suffix = suffix .. (" "):rep(target_width - cursor_width - chunk_width)
      end
      break
    end

    cursor_width = cursor_width + chunk_width
  end

  return result
end

return M
