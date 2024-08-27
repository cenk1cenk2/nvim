local M = {}

function M.setup()
  require("ck.setup").init({
    commands = {
      {
        "LspToggleFormatOnSave",
        function()
          require("ck.lsp.format").toggle_format_on_save()
        end,
      },
      {
        "LspSetLogLevel",
        function(nargs)
          local level = table.remove(nargs.fargs, 1)
          nvim.lsp.fn.set_log_level(level)
        end,
        complete = function()
          return require("ck.log").levels
        end,
        nargs = 1,
      },
      {
        "LspOrganizeImports",
        function()
          nvim.lsp.fn.organize_imports()
        end,
      },
      {
        "LspRenameFile",
        function()
          nvim.lsp.fn.rename_file()
        end,
      },
    },
  })
end

return M
