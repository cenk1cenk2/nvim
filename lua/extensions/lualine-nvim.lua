-- https://github.com/nvim-lualine/lualine.nvim
local M = {}

local extension_name = "lualine_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-lualine/lualine.nvim",
        config = function()
          require("utils.setup").packer_config "lualine_nvim"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      local colors = {
        bg = "#202328",
        fg = "#bbc2cf",
        yellow = "#ECBE7B",
        cyan = "#008080",
        darkblue = "#081633",
        green = "#98be65",
        orange = "#FF8800",
        violet = "#a9a1e1",
        magenta = "#c678dd",
        purple = "#c678dd",
        blue = "#51afef",
        red = "#ec5f67",
      }

      local window_width_limit = 70

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand "%:t") ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > window_width_limit
        end,
      }

      return {
        components = {
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

              return " " .. mode_name[vim.fn.mode()] .. " "
            end,
            padding = { left = 0, right = 0 },
            color = { fg = colors.bg },
            cond = nil,
          },
          branch = {
            "b:gitsigns_head",
            icon = "",
            color = { fg = colors.bg, bg = colors.yellow },
            cond = conditions.hide_in_width,
          },
          filetype = { "filetype", cond = conditions.hide_in_width, color = {} },
          filename = { "filename", color = {}, cond = nil },
          diff = {
            "diff",
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
              end
            end,
            symbols = { added = "  ", modified = " ", removed = " " },
            diff_color = {
              added = { fg = colors.green },
              modified = { fg = colors.yellow },
              removed = { fg = colors.red },
            },
            cond = nil,
          },
          python_env = {
            function()
              local utils = require "lvim.core.lualine.utils"
              if vim.bo.filetype == "python" then
                local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
                if venv then
                  return string.format("  (%s)", utils.env_cleanup(venv))
                end
              end
              return ""
            end,
            color = { fg = colors.green },
            cond = conditions.hide_in_width,
          },
          diagnostics = {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            cond = conditions.hide_in_width,
          },
          treesitter = {
            function()
              return ""
            end,
            color = function()
              local buf = vim.api.nvim_get_current_buf()
              local ts = vim.treesitter.highlighter.active[buf]
              return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
            end,
            cond = conditions.hide_in_width,
          },
          lsp = {
            function(msg)
              msg = msg or "❌"
              local buf_clients = vim.lsp.get_active_clients { bufnr = vim.api.nvim_get_current_buf() }
              if next(buf_clients) == nil then
                -- TODO: clean up this if statement
                if type(msg) == "boolean" or #msg == 0 then
                  return "❌"
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
              local formatters = require "lvim.lsp.null-ls.formatters"
              local supported_formatters = formatters.list_registered(buf_ft)

              -- add linter
              local linters = require "lvim.lsp.null-ls.linters"
              local supported_linters = linters.list_registered(buf_ft)

              local lsps = table.concat(buf_client_names, ", ")

              if supported_linters and not vim.tbl_isempty(supported_linters) then
                lsps = lsps .. " | 📋 " .. table.concat(supported_linters, ", ")
              end

              if supported_formatters and not vim.tbl_isempty(supported_formatters) then
                lsps = lsps .. " | ✍ " .. table.concat(supported_formatters, ", ")
              end

              return lsps
            end,
            color = { gui = "bold" },
            cond = conditions.hide_in_width,
          },
          location = { "location", cond = conditions.hide_in_width, color = {} },
          progress = { "progress", cond = conditions.hide_in_width, color = {} },
          spaces = {
            function()
              if not vim.api.nvim_buf_get_option(0, "expandtab") then
                return "Tab size: " .. vim.api.nvim_buf_get_option(0, "tabstop") .. " "
              end
              local size = vim.api.nvim_buf_get_option(0, "shiftwidth")
              if size == 0 then
                size = vim.api.nvim_buf_get_option(0, "tabstop")
              end
              return "Spaces: " .. size .. " "
            end,
            cond = conditions.hide_in_width,
            color = {},
          },
          encoding = {
            "o:encoding",
            fmt = string.upper,
            color = {},
            cond = conditions.hide_in_width,
          },
          scrollbar = {
            function()
              local current_line = vim.fn.line "."
              local total_lines = vim.fn.line "$"
              local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
              local line_ratio = current_line / total_lines
              local index = math.ceil(line_ratio * #chars)
              return chars[index]
            end,
            padding = { left = 0, right = 0 },
            color = { fg = colors.yellow, bg = colors.bg },
            cond = nil,
          },
        },
      }
    end,
    setup = function(config)
      local components = config.inject.components

      return {
        options = {
          theme = "auto",
          icons_enabled = lvim.use_icons,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { "alpha", "NvimTree", "Outline" },
        },
        sections = {
          lualine_a = { components.mode },
          lualine_b = { components.branch, components.filetype, components.filename },
          lualine_c = { components.diff, components.python_env },
          lualine_x = { components.diagnostics, components.treesitter, components.lsp },
          lualine_y = {},
          lualine_z = { components.scrollbar },
        },
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        tabline = nil,
        extensions = { "nvim-tree" },
      }
    end,
    on_setup = function(config)
      require("lualine").setup(config.setup)
    end,
  })
end

return M
