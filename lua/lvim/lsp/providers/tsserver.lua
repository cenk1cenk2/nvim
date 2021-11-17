local Log = require "lvim.core.log"

local opts = {
  settings = {
    preferences = {
      importModuleSpecifier = "relative",
    },
  },
  commands = {
    LspRenameFile = {
      function()
        vim.call "inputsave"

        local current = vim.api.nvim_buf_get_name(0)
        local rename = vim.fn.input("Set the path to rename to" .. " ➜  ", current)

        vim.api.nvim_command "normal :esc<CR>"

        vim.api.nvim_out_write(current .. " ➜  " .. rename .. "\n")

        local stat = vim.loop.fs_stat(rename)

        if stat and stat.type then
          Log:warn("File already exists: " .. rename)

          return
        end

        vim.lsp.buf.execute_command {
          command = "_typescript.applyRenameFile",
          arguments = { { sourceUri = "file://" .. current, targetUri = "file://" .. rename } },
          title = "",
        }

        vim.loop.fs_rename(current, rename)

        for _, buf in pairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            if vim.api.nvim_buf_get_name(buf) == current then
              vim.api.nvim_buf_set_name(buf, rename)
              -- to avoid the 'overwrite existing file' error message on write
              vim.api.nvim_buf_call(buf, function()
                vim.cmd "silent! w!"
              end)
            end
          end
        end

        vim.call "inputrestore"
      end,
    },

    LspOrganizeImports = {
      function()
        local params = {
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
          title = "",
        }
        vim.lsp.buf.execute_command(params)
      end,
    },
  },
}
return opts
