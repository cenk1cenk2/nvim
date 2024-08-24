local M = {}

function M.setup()
  require("setup").init({
    commands = {
      {
        "QuickFixToggle",
        function()
          local qf = vim.tbl_filter(function(win)
            if win.quickfix == 1 then
              return true
            end

            return false
          end, vim.fn.getwininfo())

          if vim.tbl_isempty(qf) then
            vim.cmd("botright copen")
          else
            vim.cmd("cclose")
          end
        end,
      },
      {
        "NvimToggleFormatOnSave",
        function()
          require("core.lsp.format").toggle_format_on_save()
        end,
      },
      {
        "NvimCacheReset",
        function()
          require("core.loader").reset_cache()
        end,
      },
      {
        "NvimReload",
        function()
          require("core.config"):reload()
        end,
      },
      {
        "NvimUpdate",
        function()
          require("core"):update()
        end,
      },
      {
        "NvimVersion",
        function()
          require("core.log"):info(require("core.version").get_nvim_version())
        end,
      },
      {
        "NvimOpenlog",
        function()
          vim.cmd(("edit %s"):format(require("core.log").get_path()))
        end,
      },
    },
  })
end

return M
