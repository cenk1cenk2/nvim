-- https://github.com/nvim-lualine/lualine.nvim
local M = {}

local extension_name = "lualine_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        -- event = "VeryLazy",
      }
    end,
    inject_to_configure = function()
      local window_width_limit = 70

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > window_width_limit
        end,
      }

      local components = {
        mode = {
          function()
            local mode_name = {
              c = "COMMAND",
              i = "INSERT",
              ic = "INSERT COMP",
              ix = "INSERT COMP",
              multi = "MULTI",
              n = "NORMAL",
              ni = "(INSERT)",
              no = "OP PENDING",
              R = "REPLACE",
              Rv = "V REPLACE",
              s = "SELECT",
              S = "S-LINE",
              [""] = "S-BLOCK",
              t = "TERMINAL",
              v = "VISUAL",
              V = "V-LINE",
              [""] = "V-BLOCK",
            }

            return mode_name[vim.fn.mode()]
          end,
          padding = { left = 1, right = 1 },
          color = { fg = lvim.ui.colors.black },
        },
        branch = {
          "b:gitsigns_head",
          icon = lvim.ui.icons.git.Branch,
          color = { fg = lvim.ui.colors.black, bg = lvim.ui.colors.yellow[300] },
          cond = conditions.hide_in_width,
        },
        filetype = {
          "filetype",
          cond = conditions.hide_in_width,
          color = {
            fg = lvim.ui.colors.fg,
            bg = lvim.ui.colors.bg[300],
          },
        },
        filename = {
          "filename",
          color = {
            fg = lvim.ui.colors.fg,
            bg = lvim.ui.colors.bg[300],
          },
        },
        diff = {
          "diff",
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict

            if gitsigns then
              return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
            end
          end,
          symbols = { added = lvim.ui.icons.git.LineAdded .. " ", modified = lvim.ui.icons.git.LineModified .. " ", removed = lvim.ui.icons.git.LineModified .. " " },
          diff_color = {
            added = { fg = lvim.ui.colors.green[600] },
            modified = { fg = lvim.ui.colors.blue[600] },
            removed = { fg = lvim.ui.colors.red[600] },
          },
          color = {
            bg = lvim.ui.colors.bg[300],
          },
          cond = conditions.hide_in_width,
        },
        python_env = {
          function()
            local utils = require("lvim.core.lualine.utils")
            if vim.bo.filetype == "python" then
              local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
              if venv then
                return string.format("  (%s)", utils.env_cleanup(venv))
              end
            end
            return ""
          end,
          color = {
            fg = lvim.ui.colors.green[300],
            bg = lvim.ui.colors.bg[300],
          },
          cond = conditions.hide_in_width,
        },
        diagnostics = {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = lvim.ui.icons.diagnostics.Error .. " ",
            warn = lvim.ui.icons.diagnostics.Warning .. " ",
            info = lvim.ui.icons.diagnostics.Information .. " ",
            hint = lvim.ui.icons.diagnostics.Hint .. " ",
          },
          cond = conditions.hide_in_width,
        },
        treesitter = {
          function()
            return lvim.ui.icons.ui.Tree
          end,
          color = function()
            local buf = vim.api.nvim_get_current_buf()
            local ts = vim.treesitter.highlighter.active[buf]

            return {
              fg = ts and not vim.tbl_isempty(ts) and lvim.ui.colors.green[300] or lvim.ui.colors.red[300],
              bg = lvim.ui.colors.bg[300],
            }
          end,
          cond = conditions.hide_in_width,
        },
        lsp = {
          function(msg)
            local buf_clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

            if next(buf_clients) == nil then
              -- TODO: clean up this if statement
              if type(msg) == "boolean" or #msg == 0 then
                return lvim.ui.icons.ui.Close
              end

              return msg
            end

            local buf_ft = vim.bo.filetype
            local buf_client_names = {}

            -- add client
            for _, client in pairs(buf_clients) do
              if client.name ~= "null-ls" then
                table.insert(buf_client_names, client.name)
              end
            end

            -- add formatter
            local null_ls_service = require("lvim.lsp.null-ls")
            local null_ls_methods = require("null-ls").methods
            local supported_formatters = null_ls_service.list_registered(buf_ft, { null_ls_methods.FORMATTING })
            local supported_linters = null_ls_service.list_registered(buf_ft, {
              null_ls_methods.DIAGNOSTICS,
              null_ls_methods.DIAGNOSTICS_ON_SAVE,
              null_ls_methods.DIAGNOSTICS_ON_OPEN,
            })

            local lsps = table.concat(buf_client_names, ", ")

            if supported_linters and not vim.tbl_isempty(supported_linters) then
              lsps = lsps .. (" %s "):format(lvim.ui.icons.ui.DoubleChevronRight) .. table.concat(supported_linters, ", ")
            end

            if supported_formatters and not vim.tbl_isempty(supported_formatters) then
              lsps = lsps .. (" %s "):format(lvim.ui.icons.ui.DoubleChevronRight) .. table.concat(supported_formatters, ", ")
            end

            return lsps
          end,
          color = { fg = lvim.ui.colors.fg, bg = lvim.ui.colors.bg[300] },
          cond = conditions.hide_in_width,
        },
        location = { "location", cond = conditions.hide_in_width, color = {} },
        progress = { "progress", cond = conditions.hide_in_width, color = {} },
        ff = {
          function()
            local ff = vim.api.nvim_buf_get_option(0, "ff"):upper()

            if ff == "UNIX" then
              return lvim.ui.icons.misc.Linux
            elseif ff == "DOS" then
              return lvim.ui.icons.misc.Windows
            end

            return ff
          end,
          cond = conditions.hide_in_width,
          color = { fg = lvim.ui.colors.bg[600], bg = lvim.ui.colors.bg[300] },
        },
        spaces = {
          function()
            if not vim.api.nvim_buf_get_option(0, "expandtab") then
              return ("%s%s"):format(lvim.ui.icons.ui.Tab, vim.api.nvim_buf_get_option(0, "tabstop"))
            end
            local size = vim.api.nvim_buf_get_option(0, "shiftwidth")
            if size == 0 then
              size = vim.api.nvim_buf_get_option(0, "tabstop")
            end
            return ("%s%s"):format(lvim.ui.icons.ui.BoldLineLeft, size)
          end,
          cond = conditions.hide_in_width,
          fmt = string.upper,
          color = { fg = lvim.ui.colors.bg[600], bg = lvim.ui.colors.bg[300] },
        },
        encoding = {
          "o:encoding",
          fmt = string.upper,
          color = { fg = lvim.ui.colors.bg[600], bg = lvim.ui.colors.bg[300] },
          cond = conditions.hide_in_width,
        },
        scrollbar = {
          function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return chars[index]
          end,
          padding = { left = 0, right = 0 },
          color = { fg = lvim.ui.colors.yellow[300], bg = lvim.ui.colors.grey[300] },
          cond = nil,
        },
      }

      local noice_ok = pcall(require, "noice")

      if noice_ok then
        components.noice_left = {
          {
            function()
              return require("noice").api.statusline.message.get_hl()
            end,
            cond = function()
              return require("noice").api.statusline.message.has()
            end,
          },
        }
        components.noice_right = {
          -- {
          --   function()
          --     return require("noice").api.statusline.search.get()
          --   end,
          --   cond = function()
          --     return require("noice").api.statusline.search.has()
          --   end,
          --   color = { fg = colors.cyan[600] },
          -- },
          {
            function()
              return require("noice").api.statusline.mode.get()
            end,
            cond = function()
              return require("noice").api.statusline.mode.has()
            end,
            color = { fg = lvim.ui.colors.yellow[600] },
          },
          {
            function()
              return require("noice").api.statusline.command.get()
            end,
            cond = function()
              return require("noice").api.statusline.command.has()
            end,
            color = { fg = lvim.ui.colors.blue[600] },
          },
        }
      else
        components.noice_left = {}
        components.noice_right = {}
      end

      return {
        components = components,
      }
    end,
    setup = function(config)
      local components = config.inject.components

      return {
        globalstatus = true,
        options = {
          theme = "auto",
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = lvim.disabled_filetypes,
        },
        sections = {
          lualine_a = { components.mode },
          lualine_b = {
            components.branch,
            components.filetype,
            -- components.filename,
            components.diff,
            components.python_env,
          },
          lualine_c = components.noice_left,
          lualine_x = components.noice_right,
          lualine_y = {
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = { fg = lvim.ui.colors.yellow[900] },
            },
            components.ff,
            components.spaces,
            -- components.encoding,
            components.diagnostics,
            components.treesitter,
            components.lsp,
          },
          lualine_z = { components.scrollbar },
        },
        inactive_sections = {
          lualine_a = { components.mode },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        -- winbar = {
        --   lualine_a = {},
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = {},
        -- },
        -- inactive_winbar = {
        --   lualine_a = {},
        --   lualine_b = {},
        --   lualine_c = {},
        --   lualine_x = {},
        --   lualine_y = {},
        --   lualine_z = {},
        -- },
        tabline = nil,
        extensions = { "nvim-tree", "aerial", "quickfix", "nvim-dap-ui", "toggleterm" },
      }
    end,
    on_setup = function(config)
      require("lualine").setup(config.setup)
    end,
  })
end

return M
