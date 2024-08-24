local M = {}

function M.setup()
  require("ck.setup").init({
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
          require("ck.lsp.format").toggle_format_on_save()
        end,
      },
      {
        "NvimCacheReset",
        function()
          require("ck.loader").reset_cache()
        end,
      },
      {
        "NvimReload",
        function()
          require("ck.config"):reload()
        end,
      },
      {
        "NvimUpdate",
        function()
          require("ck"):update()
        end,
      },
      {
        "NvimVersion",
        function()
          require("ck.log"):info(require("ck.version").get_nvim_version())
        end,
      },
      {
        "NvimOpenlog",
        function()
          vim.cmd(("edit %s"):format(require("ck.log").get_path()))
        end,
      },
    },
  })
end

return M
