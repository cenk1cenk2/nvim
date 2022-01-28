local Log = require "lvim.core.log"

local opts = {
  settings = {
    typescript = {
      importModuleSpecifier = "non-relative",
      preferences = {
        importModuleSpecifier = "non-relative",
      },
      inlayHints = {
        parameterNames = "all",
        variableTypes = {
          enabled = true,
        },
        propertyDeclarationTypes = {
          enabled = true,
        },
        parameterTypes = {
          enabled = true,
        },
        functionLikeReturnTypes = {
          enabled = true,
        },
      },
      referencesCodeLens = {
        enabled = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
    },
  },
  -- Needed for inlayHints. Merge this table with your settings or copy
  -- it from the source if you want to add your own init_options.
  init_options = require("nvim-lsp-ts-utils").init_options,
  on_attach = function(client, bufnr)
    local ts_utils = require "nvim-lsp-ts-utils"

    require("lvim.lsp").common_on_attach(client, bufnr)

    -- defaults
    ts_utils.setup {
      debug = false,
      disable_commands = false,
      enable_import_on_completion = false,

      -- import all
      import_all_timeout = 10000, -- ms
      -- lower numbers = higher priority

      import_all_priorities = {
        same_file = 1, -- add to existing import statement
        local_files = 2, -- git files or files with relative path markers
        buffer_content = 3, -- loaded buffer content
        buffers = 4, -- loaded buffer names
      },
      import_all_scan_buffers = 100,
      import_all_select_source = true,

      -- filter diagnostics
      filter_out_diagnostics_by_severity = {},
      filter_out_diagnostics_by_code = {},

      -- inlay hints
      auto_inlay_hints = true,
      inlay_hints_highlight = "TSInlayHint",

      -- update imports on file move
      update_imports_on_move = true,
      require_confirmation_on_move = true,
      watch_dir = nil,
    }

    -- required to fix code action ranges and filter diagnostics
    ts_utils.setup_client(client)
  end,
  commands = {
    LspRenameFile = {
      function()
        local current = vim.api.nvim_buf_get_name(0)
        vim.ui.input({ prompt = "Set the path to rename to" .. " ➜  ", default = current }, function(rename)
          if not rename then
            Log:warn "File name can not be empty."

            return
          end

          Log:info(current .. " ➜  " .. rename)

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
        end)
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
