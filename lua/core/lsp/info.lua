local M = {}

local lsp_utils = require("core.lsp.utils")
M.is_open = false
M.instance = nil

function M.generate_popup(opts)
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local popup = Popup(vim.tbl_deep_extend("force", {
    enter = true,
    focusable = false,
    border = {
      style = lvim.ui.border,
      text = {
        -- top = "LSP Info",
        top_align = "center",
      },
    },
    buf_options = {
      modifiable = true,
      readonly = false,
    },
    win_options = {
      winblend = 10,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  }, opts))

  popup:map("n", "q", function()
    M.hide()
  end, { noremap = true })

  popup:on(event.BufLeave, function()
    M.hide()
  end)

  vim.api.nvim_set_option_value("filetype", "lspinfo", { buf = popup.bufnr })
  vim.api.nvim_set_option_value("wrap", false, { win = popup.win_id })

  return popup
end

function M.show()
  M.lsp_info(vim.api.nvim_get_current_buf())
  M.instance:mount()
end

function M.hide()
  M.instance:unmount()
end

function M.toggle()
  M.show()
end

function M.lsp_info(bufnr)
  local Layout = require("nui.layout")

  local popup_buffer_info = M.generate_popup({
    border = {
      text = {
        top = "Buffer Information",
      },
    },
  })

  local popup_buffer_lsp_info = M.generate_popup({
    border = {
      text = {
        top = "Current Buffer LSP Clients",
      },
    },
  })

  local popup_buffer_tools_info = M.generate_popup({
    border = {
      text = {
        top = "Current Buffer Tools",
      },
    },
  })

  local popup_lsp_info = M.generate_popup({
    border = {
      text = {
        top = "Lsp Clients",
      },
    },
  })

  M.instance = Layout(
    {
      relative = "editor",
      size = {
        height = "75%",
        width = "75%",
      },
      position = "50%",
    },
    Layout.Box({
      Layout.Box(popup_buffer_info, {
        size = {
          height = "20%",
        },
      }),
      Layout.Box(popup_buffer_lsp_info, {
        size = {
          height = "25%",
        },
      }),
      Layout.Box(popup_buffer_tools_info, {
        size = {
          height = "25%",
        },
      }),
      Layout.Box(popup_lsp_info, {
        grow = 1,
      }),
    }, { dir = "col" })
  )

  M.generate_buffer_info(popup_buffer_info, bufnr)
  M.generate_buffer_lsp_info(popup_buffer_lsp_info, bufnr)
  M.generate_current_buffer_tools_info(popup_buffer_tools_info, bufnr)
  M.generate_lsp_info(popup_lsp_info, bufnr)
end

function M.generate_buffer_info(popup, bufnr)
  local Text = require("nui.text")
  local Table = require("nui.table")

  Table({
    bufnr = popup.bufnr,
    columns = {
      {
        align = "center",
        accessor_key = "filetype",
        width = 20,
        header = "File Type",
        cell = function(cell)
          return Text(tostring(cell.get_value()), "DiagnosticWarn")
        end,
      },
      {
        align = "center",
        width = 20,
        header = "bufnr",
        accessor_key = "bufnr",
        cell = function(cell)
          return Text(tostring(cell.get_value()))
        end,
      },
      {
        align = "center",
        width = 20,
        header = "treesitter",
        accessor_key = "treesitter",
        cell = function(cell)
          return Text(tostring(cell.get_value()))
        end,
      },
    },
    data = {
      {
        filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr }),
        bufnr = bufnr,
        treesitter = vim.tbl_contains(vim.tbl_keys(vim.treesitter.highlighter.active), bufnr),
      },
    },
  }):render()
end

function M.generate_buffer_lsp_info(popup, bufnr)
  local Text = require("nui.text")
  local Table = require("nui.table")

  --- @param client lsp.Client
  local data = vim.tbl_map(function(client)
    return {
      name = client.name,
      id = client.id,
      filetypes = client.config.filetypes,
      attached_buffers = vim.lsp.get_buffers_by_client_id(client.id),
      root_dir = client.config.root_dir,
      capabilities = lsp_utils.get_client_capabilities(client.id),
    }
  end, vim.lsp.get_clients({ bufnr = bufnr }))

  Table({
    bufnr = popup.bufnr,
    columns = {
      {
        align = "center",
        header = "Name",
        accessor_key = "name",
        cell = function(cell)
          return Text(tostring(cell.get_value()), "DiagnosticWarn")
        end,
      },
      {
        align = "center",
        header = "Root",
        accessor_key = "root_dir",
        cell = function(cell)
          return Text(tostring(cell.get_value()))
        end,
      },
      {
        width = 40,
        align = "center",
        header = "Capabilities",
        accessor_key = "capabilities",
        cell = function(cell)
          return Text(table.concat(cell.get_value() or {}, ", "))
        end,
      },
    },
    data = data,
  }):render()
end

function M.generate_lsp_info(popup, bufnr)
  local Text = require("nui.text")
  local Table = require("nui.table")

  --- @param client lsp.Client
  local data = vim.tbl_map(function(client)
    return {
      name = client.name,
      id = client.id,
      filetypes = client.config.filetypes,
      attached_buffers = vim.lsp.get_buffers_by_client_id(client.id),
      root_dir = client.config.root_dir,
      capabilities = lsp_utils.get_client_capabilities(client.id),
    }
  end, vim.lsp.get_clients({ bufnr = bufnr }))

  Table({
    bufnr = popup.bufnr,
    columns = {
      {
        align = "center",
        header = "Name",
        accessor_key = "name",
        cell = function(cell)
          return Text(tostring(cell.get_value()), "DiagnosticWarn")
        end,
      },
      {
        align = "center",
        header = "Root",
        accessor_key = "root_dir",
        cell = function(cell)
          return Text(tostring(cell.get_value()))
        end,
      },
      {
        width = 40,
        align = "center",
        header = "Filetypes",
        accessor_key = "filetypes",
        cell = function(cell)
          return Text(table.concat(cell.get_value() or {}, ", "))
        end,
      },
      {
        width = 40,
        align = "center",
        header = "Attached Buffers",
        accessor_key = "attached_buffers",
        cell = function(cell)
          return Text(table.concat(cell.get_value() or {}, ", "))
        end,
      },
      {
        width = 40,
        align = "center",
        header = "Capabilities",
        accessor_key = "capabilities",
        cell = function(cell)
          return Text(table.concat(cell.get_value() or {}, ", "))
        end,
      },
    },
    data = data,
  }):render()
end

function M.generate_current_buffer_tools_info(popup, bufnr)
  local Text = require("nui.text")
  local Table = require("nui.table")

  Table({
    bufnr = popup.bufnr,
    columns = {
      {
        align = "center",
        header = "Type",
        accessor_key = "type",
        cell = function(cell)
          return Text(tostring(cell.get_value()), "DiagnosticWarn")
        end,
      },
      {
        align = "center",
        header = "Tools",
        accessor_key = "value",
        cell = function(cell)
          return Text(table.concat(cell.get_value() or {}, ", "))
        end,
      },
    },
    data = {
      { type = "Linter", value = lvim.lsp.tools.list_registered.linters(bufnr) },
      { type = "Formatter", value = lvim.lsp.tools.list_registered.formatters(bufnr) },
    },
  }):render()
end

return M
