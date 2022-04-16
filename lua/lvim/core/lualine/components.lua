local conditions = require "lvim.core.lualine.conditions"
local colors = require "lvim.core.lualine.colors"

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
  end
end

return {
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
    source = diff_source,
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
        local venv = os.getenv "CONDA_DEFAULT_ENV"
        if venv then
          return string.format("  (%s)", utils.env_cleanup(venv))
        end
        venv = os.getenv "VIRTUAL_ENV"
        if venv then
          return string.format("  (%s)", utils.env_cleanup(venv))
        end
        return ""
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
      local b = vim.api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then
        return ""
      end
      return ""
    end,
    color = { fg = colors.green },
    cond = conditions.hide_in_width,
  },
  lsp = {
    function(msg)
      msg = msg or "!LS"
      local buf_clients = vim.lsp.buf_get_clients()
      if next(buf_clients) == nil then
        -- TODO: clean up this if statement
        if type(msg) == "boolean" or #msg == 0 then
          return "!LS"
        end
        return msg
      end
      local buf_ft = vim.bo.filetype
      local buf_client_names = {}

      -- add client
      for _, client in ipairs(buf_clients) do
        -- print(vim.inspect(client.name))
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
        lsps = lsps .. " | lint: " .. table.concat(supported_linters, ", ")
      end

      if supported_formatters and not vim.tbl_isempty(supported_formatters) then
        lsps = lsps .. " | format: " .. table.concat(supported_formatters, ", ")
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
  filetype = { "filetype", cond = conditions.hide_in_width },
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
}
