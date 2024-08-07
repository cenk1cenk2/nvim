-- https://github.com/nvim-lualine/lualine.nvim
local M = {}

local extension_name = "lualine_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-lualine/lualine.nvim",
        event = "UIEnter",
      }
    end,
    setup = function()
      local components = M.components()

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
            components.iedit,
          },
          lualine_c = {
            components.noice_message,
          },
          lualine_x = {
            components.noice_mode,
            components.noice_command,
          },
          lualine_y = {
            components.lazy_updates,
            components.location,
            components.ff,
            components.spaces,
            -- components.encoding,
            components.session,
            components.arrow,
            components.dap,
            components.diagnostics,
            components.treesitter,
            components.yaml_schema,
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

function M.components()
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
    yaml_schema = {
      function()
        return ("%s %s"):format(lvim.ui.icons.ui.Table, require("yaml-companion").get_buffer_schema(0).name)
      end,
      color = {
        fg = lvim.ui.colors.purple[600],
        bg = lvim.ui.colors.bg[300],
      },
      cond = function()
        return conditions.hide_in_width() and vim.tbl_contains({ "yaml", "helm" }, vim.api.nvim_get_option_value("ft", { buf = 0 })) and package_is_loaded("yaml-companion")
      end,
    },
    arrow = {
      function()
        return require("arrow.statusline").text_for_statusline_with_icons()
      end,
      color = {
        fg = lvim.ui.colors.green[600],
        bg = lvim.ui.colors.bg[300],
      },
      cond = function()
        return conditions.hide_in_width() and package_is_loaded("arrow")
      end,
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
    session = {
      function()
        return ("%s"):format(lvim.ui.icons.ui.History)
      end,
      color = function()
        return {
          fg = lvim.ui.colors.green[300],
          bg = lvim.ui.colors.bg[300],
        }
      end,
      cond = function()
        if not package_is_loaded("possession") or require("possession").session_name == "" then
          return false
        end

        return conditions.hide_in_width()
      end,
    },
    dap = {
      function()
        return ("%s - %s"):format(lvim.ui.icons.ui.Bug, require("dap").status())
      end,
      color = function()
        return {
          fg = lvim.ui.colors.yellow[300],
          bg = lvim.ui.colors.bg[300],
        }
      end,
      cond = function()
        if not package_is_loaded("dap") or require("dap").status() == "" then
          return false
        end

        return conditions.hide_in_width()
      end,
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
        local bufnr = vim.api.nvim_get_current_buf()

        local buf_clients = vim.tbl_map(function(client)
          return client.name
        end, vim.lsp.get_clients({ bufnr = bufnr }))

        -- add formatter
        local message = { table.concat(buf_clients or { lvim.ui.icons.ui.Close }, ", ") }

        local supported_linters = lvim.lsp.tools.list_registered.linters(bufnr)

        if supported_linters and not vim.tbl_isempty(supported_linters) then
          vim.list_extend(message, { ("%s %s"):format(lvim.ui.icons.ui.DoubleChevronRight, table.concat(supported_linters, ", ")) })
        end

        local supported_formatters = lvim.lsp.tools.list_registered.formatters(bufnr)

        if supported_formatters and not vim.tbl_isempty(supported_formatters) then
          vim.list_extend(message, { ("%s %s"):format(lvim.ui.icons.ui.DoubleChevronRight, table.concat(supported_formatters, ", ")) })
        end

        return table.concat(message, " ")
      end,
      color = { fg = lvim.ui.colors.fg, bg = lvim.ui.colors.bg[300] },
      cond = conditions.hide_in_width,
    },
    progress = {
      "progress",
      cond = conditions.hide_in_width,
      color = {},
    },
    location = {
      "location",
      color = { fg = lvim.ui.colors.blue[300], bg = lvim.ui.colors.bg[300] },
    },
    ff = {
      "fileformat",
      cond = conditions.hide_in_width,
      color = { fg = lvim.ui.colors.bg[600], bg = lvim.ui.colors.bg[300] },
    },
    spaces = {
      function()
        if not vim.bo.expandtab then
          return ("%s %s"):format(lvim.ui.icons.ui.Tab, vim.bo.tabstop)
        end
        local size = vim.bo.shiftwidth
        if size == 0 then
          size = vim.bo.tabstop
        end

        return ("%s %s"):format(lvim.ui.icons.ui.Space, size)
      end,
      cond = conditions.hide_in_width,
      fmt = string.upper,
      color = { fg = lvim.ui.colors.bg[600], bg = lvim.ui.colors.bg[300] },
    },
    encoding = {
      "encoding",
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
      color = { fg = lvim.ui.colors.yellow[300], bg = lvim.ui.colors.gray[300] },
      cond = nil,
    },
    iedit = {
      function()
        return lvim.ui.icons.ui.Pencil
      end,
      color = { fg = lvim.ui.colors.black, bg = lvim.ui.colors.orange[600] },
      cond = function()
        return package_is_loaded("iedit") and require("extensions.iedit-nvim").is_active()
      end,
    },
    lazy_updates = {
      function()
        return require("lazy.status").updates()
      end,
      cond = function()
        return package_is_loaded("lazy") and require("lazy.status").has_updates()
      end,
      color = { fg = lvim.ui.colors.yellow[900] },
    },
    noice_message = {
      function()
        return require("noice").api.statusline.message.get_hl()
      end,
      cond = function()
        return package_is_loaded("noice") and require("noice").api.statusline.message.has()
      end,
    },
    noice_search = {
      function()
        return require("noice").api.statusline.search.get()
      end,
      color = { fg = lvim.ui.colors.cyan[600] },
      cond = function()
        return package_is_loaded("noice") and require("noice").api.statusline.search.has()
      end,
    },
    noice_mode = {
      function()
        return require("noice").api.statusline.mode.get()
      end,
      color = { fg = lvim.ui.colors.yellow[600] },
      cond = function()
        return package_is_loaded("noice") and require("noice").api.statusline.mode.has()
      end,
    },
    noice_command = {
      function()
        return require("noice").api.statusline.command.get()
      end,
      color = { fg = lvim.ui.colors.blue[600] },
      cond = function()
        return package_is_loaded("noice") and require("noice").api.statusline.command.has()
      end,
    },
  }

  return components
end

return M
