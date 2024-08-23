local M = {}

function M.setup()
  require("utils.setup").init({
    name = "commands",
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
        "LvimToggleFormatOnSave",
        function()
          require("lvim.lsp.format").toggle_format_on_save()
        end,
      },
      {
        "LvimCacheReset",
        function()
          require("lvim.loader").reset_cache()
        end,
      },
      {
        "LvimReload",
        function()
          require("lvim.config"):reload()
        end,
      },
      {
        "LvimUpdate",
        function()
          require("lvim"):update()
        end,
      },
      {
        "LvimVersion",
        function()
          print(require("lvim.version").get_lvim_version())
        end,
      },
      {
        "LvimOpenlog",
        function()
          vim.fn.execute("edit " .. require("lvim.log").get_path())
        end,
      },
    },
  })
end

return M
