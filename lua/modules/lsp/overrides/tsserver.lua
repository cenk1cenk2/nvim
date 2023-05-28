local Log = require("lvim.core.log")

return {
  settings = {
    typescript = {
      preferences = {
        importModuleSpecifier = "relative",
      },
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  commands = {
    LspRenameFile = {
      function()
        local current = vim.api.nvim_buf_get_name(0)
        vim.ui.input({ prompt = "Set the path to rename to" .. " ➜  ", default = current }, function(rename)
          if not rename then
            vim.notify("File name can not be empty.", vim.log.levels.ERROR)

            return
          end

          vim.notify(current .. " ➜  " .. rename)

          local stat = vim.loop.fs_stat(rename)

          if stat and stat.type then
            vim.notify("File already exists: " .. rename, vim.log.levels.ERROR)

            return
          end

          vim.lsp.buf.execute_command({
            command = "_typescript.applyRenameFile",
            arguments = { { sourceUri = "file://" .. current, targetUri = "file://" .. rename } },
            title = "",
          })

          vim.loop.fs_rename(current, rename)

          for _, buf in pairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              if vim.api.nvim_buf_get_name(buf) == current then
                vim.api.nvim_buf_set_name(buf, rename)
                -- to avoid the 'overwrite existing file' error message on write
                vim.api.nvim_buf_call(buf, function()
                  vim.cmd("silent! w!")
                end)
              end
            end
          end
        end)
      end,
    },

    LspOrganizeImports = {
      function()
        vim.lsp.buf.execute_command({
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
          title = "",
        })
      end,
    },

    LspImportAll = {
      function()
        vim.cmd([[TSLspImportAll]])
      end,
    },

    LspImportCurrent = {
      function()
        vim.cmd([[TSLspImportCurrent]])
      end,
    },
  },
}
